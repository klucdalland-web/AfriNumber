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
@php
    $bg = \App\Support\Brand::color('background', '#F6F4EF');
    $fg = \App\Support\Brand::color('foreground', '#1C1A17');
    $card = \App\Support\Brand::color('card', '#FCFAF7');
    $muted = \App\Support\Brand::color('muted', '#EDE9E1');
    $mutedFg = \App\Support\Brand::color('muted_foreground', '#6B655C');
    $border = \App\Support\Brand::color('border', '#D4CFC4');
    $primary = \App\Support\Brand::color('primary', '#1C1A17');
    $primaryFg = \App\Support\Brand::color('primary_foreground', '#F6F4EF');
    $warning = \App\Support\Brand::color('warning', '#8A6A28');
    $warningBg = \App\Support\Brand::color('warning_bg', '#F4EBD8');
    $warningBorder = \App\Support\Brand::color('warning_border', '#D9C48A');
    $logoWhite = $logoWhiteUrl ?? \App\Support\Brand::logoWhiteUrl();
@endphp
<body style="margin:0;padding:0;background-color:{{ $bg }};font-family:Arial,Helvetica,sans-serif;-webkit-font-smoothing:antialiased;">
    <div style="display:none;font-size:1px;line-height:1px;max-height:0;max-width:0;opacity:0;overflow:hidden;mso-hide:all;">
        Votre code {{ $appName }} : {{ $otp }} — expire le {{ $expiresAtLabel }}.
    </div>
    <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="background-color:{{ $bg }};padding:40px 16px;">
        <tr>
            <td align="center">
                <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="max-width:520px;background-color:{{ $card }};border-radius:12px;overflow:hidden;border:1px solid {{ $border }};">
                    <tr>
                        <td style="background-color:{{ $primary }};padding:32px 40px 28px;text-align:center;">
                            <img src="{{ $logoWhite }}" alt="{{ $appName }}" width="56" height="56" style="display:block;margin:0 auto 14px;width:56px;height:56px;object-fit:contain;border:0;">
                            <p style="margin:0;font-family:Arial,Helvetica,sans-serif;font-size:22px;font-weight:700;letter-spacing:-0.02em;color:{{ $primaryFg }};">
                                {{ $appName }}
                            </p>
                            <p style="margin:10px 0 0;font-family:Arial,Helvetica,sans-serif;font-size:12px;letter-spacing:0.14em;text-transform:uppercase;color:{{ $border }};">
                                Vérification de sécurité
                            </p>
                        </td>
                    </tr>

                    <tr>
                        <td style="padding:36px 40px 16px;">
                            <h1 style="margin:0 0 12px;font-family:Arial,Helvetica,sans-serif;font-size:22px;font-weight:700;color:{{ $fg }};line-height:1.3;letter-spacing:-0.02em;">
                                Voici votre code
                            </h1>
                            <p style="margin:0 0 28px;font-family:Arial,Helvetica,sans-serif;font-size:15px;line-height:1.6;color:{{ $mutedFg }};">
                                Utilisez ce code pour finaliser votre authentification.
                            </p>

                            <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0">
                                <tr>
                                    <td align="center" style="background-color:{{ $muted }};border:1px solid {{ $border }};border-radius:12px;padding:28px 20px;">
                                        <p style="margin:0;font-family:'Courier New',Courier,monospace;font-size:40px;font-weight:700;letter-spacing:0.35em;color:{{ $fg }};line-height:1;">
                                            {{ $otp }}
                                        </p>
                                    </td>
                                </tr>
                            </table>

                            <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="margin-top:20px;">
                                <tr>
                                    <td align="center" style="background-color:{{ $warningBg }};border:1px solid {{ $warningBorder }};border-radius:12px;padding:16px 20px;">
                                        <p style="margin:0 0 4px;font-family:Arial,Helvetica,sans-serif;font-size:12px;letter-spacing:0.08em;text-transform:uppercase;color:{{ $warning }};">
                                            Validité du code
                                        </p>
                                        <p style="margin:0 0 6px;font-family:Arial,Helvetica,sans-serif;font-size:16px;font-weight:700;color:{{ $fg }};">
                                            Expire le {{ $expiresAtLabel }}
                                        </p>
                                        <p style="margin:0;font-family:Arial,Helvetica,sans-serif;font-size:13px;color:{{ $mutedFg }};">
                                            Valable {{ $expiresInMinutes }}&nbsp;minutes à partir de l’envoi.<br>
                                            Après cette heure, le code sera <strong style="color:{{ $warning }};">expiré</strong> — demandez-en un nouveau.
                                        </p>
                                    </td>
                                </tr>
                            </table>

                            <p style="margin:28px 0 0;font-family:Arial,Helvetica,sans-serif;font-size:14px;line-height:1.6;color:{{ $mutedFg }};">
                                Si vous n’avez pas demandé ce code, ignorez cet e-mail. Votre compte reste sécurisé.
                            </p>
                        </td>
                    </tr>

                    <tr>
                        <td style="padding:8px 40px 0;">
                            <div style="height:1px;background-color:{{ $border }};line-height:1px;font-size:1px;">&nbsp;</div>
                        </td>
                    </tr>

                    <tr>
                        <td style="padding:24px 40px 36px;text-align:center;">
                            <p style="margin:0;font-family:Arial,Helvetica,sans-serif;font-size:12px;line-height:1.5;color:{{ $mutedFg }};">
                                Message envoyé par {{ $appName }}. Merci de ne pas y répondre.
                            </p>
                        </td>
                    </tr>
                </table>

                <p style="margin:24px 0 0;font-family:Arial,Helvetica,sans-serif;font-size:11px;color:{{ $mutedFg }};">
                    &copy; {{ $copyrightYear ?? date('Y') }} {{ $appName }}. Tous droits réservés.
                </p>
            </td>
        </tr>
    </table>
</body>
</html>