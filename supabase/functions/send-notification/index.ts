import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
import { initializeApp, cert } from "npm:firebase-admin@12.1.0/app";
import { getMessaging } from "npm:firebase-admin@12.1.0/messaging";

// CORS headers for browser requests from your dashboard
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// Initialize Firebase Admin globally (runs once per function instance)
let firebaseInitialized = false;
try {
  const serviceAccountStr = Deno.env.get('FIREBASE_SERVICE_ACCOUNT');
  if (serviceAccountStr) {
    const serviceAccount = JSON.parse(serviceAccountStr);
    initializeApp({
      credential: cert(serviceAccount)
    });
    firebaseInitialized = true;
  }
} catch (error) {
  console.error("Firebase Admin Initialization Error:", error);
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { title, body, imageUrl, routePath } = await req.json();

    if (!title || !body) {
      return new Response(JSON.stringify({ error: "Missing title or body" }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      });
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const { data: tokensData, error: dbError } = await supabase
      .from('push_tokens')
      .select('token, provider')
      .eq('is_active', true);

    if (dbError) throw dbError;

    if (!tokensData || tokensData.length === 0) {
      return new Response(JSON.stringify({ message: "No active tokens found" }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const fcmTokens = tokensData.filter(t => t.provider === 'fcm' || t.provider === 'apns').map(t => t.token);
    const hmsTokens = tokensData.filter(t => t.provider === 'hms').map(t => t.token);

    let fcmSuccess = 0, fcmFail = 0;
    let hmsSuccess = 0, hmsFail = 0;

    // ─────────────────────────────────────────────────────────────────
    // 1. Send to FCM (Firebase Cloud Messaging V1 API via Admin SDK)
    // ─────────────────────────────────────────────────────────────────
    if (fcmTokens.length > 0) {
      if (firebaseInitialized) {
        // FCM limit is 500 per sendMulticast call
        for (let i = 0; i < fcmTokens.length; i += 500) {
          const chunk = fcmTokens.slice(i, i + 500);
          const message = {
            notification: {
              title: title,
              body: body,
              ...(imageUrl ? { imageUrl: imageUrl } : {})
            },
            data: {
              route: routePath || "/",
              click_action: "FLUTTER_NOTIFICATION_CLICK"
            },
            tokens: chunk,
          };

          const response = await getMessaging().sendEachForMulticast(message);
          fcmSuccess += response.successCount;
          fcmFail += response.failureCount;
        }
      } else {
        console.warn("FIREBASE_SERVICE_ACCOUNT is not set or invalid.");
      }
    }

    // ─────────────────────────────────────────────────────────────────
    // 2. Send to HMS (Huawei Push Kit)
    // ─────────────────────────────────────────────────────────────────
    if (hmsTokens.length > 0) {
      const hmsAppId = Deno.env.get('HMS_APP_ID');
      const hmsAppSecret = Deno.env.get('HMS_APP_SECRET');

      if (hmsAppId && hmsAppSecret) {
        const tokenResponse = await fetch('https://oauth-login.cloud.huawei.com/oauth2/v3/token', {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: `grant_type=client_credentials&client_id=${hmsAppId}&client_secret=${hmsAppSecret}`
        });
        
        const tokenData = await tokenResponse.json();
        const accessToken = tokenData.access_token;

        if (accessToken) {
          for (let i = 0; i < hmsTokens.length; i += 500) {
            const chunk = hmsTokens.slice(i, i + 500);
            const hmsPayload = {
              validate_only: false,
              message: {
                notification: {
                  title: title,
                  body: body,
                  image: imageUrl
                },
                android: {
                  notification: {
                    click_action: { type: 3 }
                  }
                },
                token: chunk
              }
            };

            const pushResponse = await fetch(`https://push-api.cloud.huawei.com/v1/${hmsAppId}/messages:send`, {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${accessToken}`
              },
              body: JSON.stringify(hmsPayload)
            });

            const pushResult = await pushResponse.json();
            if (pushResult.code === '80000000') {
              hmsSuccess += chunk.length;
            } else {
              hmsFail += chunk.length;
            }
          }
        }
      }
    }

    return new Response(JSON.stringify({ 
      success: true, 
      fcm: { success: fcmSuccess, fail: fcmFail },
      hms: { success: hmsSuccess, fail: hmsFail },
      totalTokens: tokensData.length
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });

  } catch (err: any) {
    console.error(err);
    return new Response(JSON.stringify({ error: err.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    });
  }
});
