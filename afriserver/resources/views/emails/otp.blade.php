<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>{{ $appName }} — Code de vérification</title>
    <!--[if mso]>
    <noscript>
        <xml>
            <o:OfficeDocumentSettings>
                <o:PixelsPerInch>96</o:PixelsPerInch>
            </o:OfficeDocumentSettings>
        </xml>
    </noscript>
    <![endif]-->
</head>
<body style="margin:0;padding:0;background-color:#eef2ee;font-family:Arial,Helvetica,sans-serif;-webkit-font-smoothing:antialiased;">
    {{-- Préheader : texte vu dans la boîte mail (évite les "...") --}}
    <div style="display:none;font-size:1px;line-height:1px;max-height:0;max-width:0;opacity:0;overflow:hidden;mso-hide:all;">
        Votre code {{ $appName }} : {{ $otp }} — expire le {{ $expiresAtLabel }}.
    </div>
    <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="background-color:#eef2ee;padding:40px 16px;">
        <tr>
            <td align="center">
                <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="max-width:520px;background-color:#ffffff;border-radius:4px;overflow:hidden;border:1px solid #d5e0d5;">
                    {{-- Header --}}
                    <tr>
                        <td style="background:linear-gradient(135deg,#1a2e1a 0%,#2d4a2d 100%);background-color:#1a2e1a;padding:36px 40px 28px;text-align:center;">
                            <p style="margin:0;font-family:Arial,Helvetica,sans-serif;font-size:26px;font-weight:700;letter-spacing:0.06em;color:#f0c14b;">
                                {{ $appName }}
                            </p>
                            <p style="margin:10px 0 0;font-family:Arial,Helvetica,sans-serif;font-size:13px;letter-spacing:0.12em;text-transform:uppercase;color:#a8c5a8;">
                                Vérification de sécurité
                            </p>
                        </td>
                    </tr>

                    {{-- Body --}}
                    <tr>
                        <td style="padding:40px 40px 16px;">
                            <h1 style="margin:0 0 12px;font-family:Arial,Helvetica,sans-serif;font-size:22px;font-weight:700;color:#152415;line-height:1.3;">
                                Voici votre code
                            </h1>
                            <p style="margin:0 0 28px;font-family:Arial,Helvetica,sans-serif;font-size:15px;line-height:1.6;color:#4a5a4a;">
                                Utilisez ce code pour finaliser votre authentification.
                            </p>

                            {{-- OTP box --}}
                            <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0">
                                <tr>
                                    <td align="center" style="background-color:#f5f8f5;border:2px dashed #c9a227;border-radius:8px;padding:28px 20px;">
                                        <p style="margin:0;font-family:'Courier New',Courier,monospace;font-size:40px;font-weight:700;letter-spacing:0.35em;color:#1a2e1a;line-height:1;">
                                            {{ $otp }}
                                        </p>
                                    </td>
                                </tr>
                            </table>

                            {{-- Expiration --}}
                            <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="margin-top:20px;">
                                <tr>
                                    <td align="center" style="background-color:#fff8e6;border:1px solid #e6c86a;border-radius:8px;padding:16px 20px;">
                                        <p style="margin:0 0 4px;font-family:Arial,Helvetica,sans-serif;font-size:12px;letter-spacing:0.08em;text-transform:uppercase;color:#8a7010;">
                                            Validité du code
                                        </p>
                                        <p style="margin:0 0 6px;font-family:Arial,Helvetica,sans-serif;font-size:16px;font-weight:700;color:#1a2e1a;">
                                            Expire le {{ $expiresAtLabel }}
                                        </p>
                                        <p style="margin:0;font-family:Arial,Helvetica,sans-serif;font-size:13px;color:#5a6a5a;">
                                            Valable {{ $expiresInMinutes }}&nbsp;minutes à partir de l’envoi.<br>
                                            Après cette heure, le code sera <strong style="color:#b45309;">expiré</strong> — demandez-en un nouveau.
                                        </p>
                                    </td>
                                </tr>
                            </table>

                            <p style="margin:28px 0 0;font-family:Arial,Helvetica,sans-serif;font-size:14px;line-height:1.6;color:#4a5a4a;">
                                Si vous n’avez pas demandé ce code, ignorez cet e-mail. Votre compte reste sécurisé.
                            </p>
                        </td>
                    </tr>

                    {{-- Divider --}}
                    <tr>
                        <td style="padding:8px 40px 0;">
                            <div style="height:1px;background-color:#d5e0d5;line-height:1px;font-size:1px;">&nbsp;</div>
                        </td>
                    </tr>

                    {{-- Footer --}}
                    <tr>
                        <td style="padding:24px 40px 36px;text-align:center;">
                            <p style="margin:0;font-family:Arial,Helvetica,sans-serif;font-size:12px;line-height:1.5;color:#7a8a7a;">
                                Cet e-mail a été envoyé automatiquement par {{ $appName }}.<br>
                                Merci de ne pas y répondre.
                            </p>
                        </td>
                    </tr>
                </table>

                <p style="margin:24px 0 0;font-family:Arial,Helvetica,sans-serif;font-size:11px;color:#8a9a8a;">
                    &copy; {{ date('Y') }} {{ $appName }}. Tous droits réservés.
                </p>
            </td>
        </tr>
    </table>
</body>
</html>
