<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>{{ $appName }} — Compte prêt</title>
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
    $logoWhite = $logoWhiteUrl ?? \App\Support\Brand::logoWhiteUrl();
@endphp
<body style="margin:0;padding:0;background-color:{{ $bg }};font-family:Arial,Helvetica,sans-serif;-webkit-font-smoothing:antialiased;">
    <div style="display:none;font-size:1px;line-height:1px;max-height:0;max-width:0;opacity:0;overflow:hidden;mso-hide:all;">
        Bonjour {{ $user->first_name }}, votre compte {{ $appName }} est prêt.
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
                                Compte prêt
                            </p>
                        </td>
                    </tr>

                    <tr>
                        <td style="padding:36px 40px 16px;">
                            <h1 style="margin:0 0 12px;font-family:Arial,Helvetica,sans-serif;font-size:22px;font-weight:700;color:{{ $fg }};line-height:1.3;letter-spacing:-0.02em;">
                                Bonjour {{ $user->first_name }}
                            </h1>
                            <p style="margin:0 0 28px;font-family:Arial,Helvetica,sans-serif;font-size:15px;line-height:1.6;color:{{ $mutedFg }};">
                                Un espace a été préparé pour vous sur {{ $appName }}. Voici les informations pour vous connecter.
                            </p>

                            <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="margin-bottom:20px;">
                                <tr>
                                    <td style="background-color:{{ $muted }};border:1px solid {{ $border }};border-radius:12px;padding:20px;">
                                        <p style="margin:0 0 8px;font-family:Arial,Helvetica,sans-serif;font-size:12px;letter-spacing:0.08em;text-transform:uppercase;color:{{ $mutedFg }};">
                                            Adresse e-mail
                                        </p>
                                        <p style="margin:0 0 16px;font-family:Arial,Helvetica,sans-serif;font-size:16px;font-weight:700;color:{{ $fg }};">
                                            <span>{{ $user->email }}</span>
                                        </p>
                                        <p style="margin:0 0 8px;font-family:Arial,Helvetica,sans-serif;font-size:12px;letter-spacing:0.08em;text-transform:uppercase;color:{{ $mutedFg }};">
                                            Mot de passe provisoire
                                        </p>
                                        <p style="margin:0;font-family:'Courier New',Courier,monospace;font-size:20px;font-weight:700;letter-spacing:0.08em;color:{{ $fg }};">
                                            <span>{{ $plainPassword }}</span>
                                        </p>
                                    </td>
                                </tr>
                            </table>

                            <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="margin-bottom:24px;">
                                <tr>
                                    <td align="center">
                                        <a href="{{ $loginUrl }}" style="display:inline-block;background-color:{{ $primary }};color:{{ $primaryFg }};text-decoration:none;font-family:Arial,Helvetica,sans-serif;font-size:14px;font-weight:700;padding:14px 28px;border-radius:10px;">
                                            Ouvrir {{ $appName }}
                                        </a>
                                    </td>
                                </tr>
                            </table>

                            <p style="margin:0;font-family:Arial,Helvetica,sans-serif;font-size:14px;line-height:1.6;color:{{ $mutedFg }};">
                                Merci de modifier ce mot de passe dès votre première connexion.
                                Si vous n’êtes pas concerné par ce message, ignorez-le ou contactez votre administrateur.
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
