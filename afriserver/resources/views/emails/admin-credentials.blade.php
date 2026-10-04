<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>{{ $appName }} — Accès administrateur</title>
</head>
<body style="margin:0;padding:0;background-color:#eef2ee;font-family:Arial,Helvetica,sans-serif;-webkit-font-smoothing:antialiased;">
    <div style="display:none;font-size:1px;line-height:1px;max-height:0;max-width:0;opacity:0;overflow:hidden;mso-hide:all;">
        Vos accès administrateur {{ $appName }} sont prêts.
    </div>
    <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="background-color:#eef2ee;padding:40px 16px;">
        <tr>
            <td align="center">
                <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="max-width:520px;background-color:#ffffff;border-radius:4px;overflow:hidden;border:1px solid #d5e0d5;">
                    <tr>
                        <td style="background:linear-gradient(135deg,#1a2e1a 0%,#2d4a2d 100%);background-color:#1a2e1a;padding:36px 40px 28px;text-align:center;">
                            <p style="margin:0;font-family:Arial,Helvetica,sans-serif;font-size:26px;font-weight:700;letter-spacing:0.06em;color:#f0c14b;">
                                {{ $appName }}
                            </p>
                            <p style="margin:10px 0 0;font-family:Arial,Helvetica,sans-serif;font-size:13px;letter-spacing:0.12em;text-transform:uppercase;color:#a8c5a8;">
                                Accès administrateur
                            </p>
                        </td>
                    </tr>

                    <tr>
                        <td style="padding:40px 40px 16px;">
                            <h1 style="margin:0 0 12px;font-family:Arial,Helvetica,sans-serif;font-size:22px;font-weight:700;color:#152415;line-height:1.3;">
                                Bonjour {{ $user->first_name }}
                            </h1>
                            <p style="margin:0 0 28px;font-family:Arial,Helvetica,sans-serif;font-size:15px;line-height:1.6;color:#4a5a4a;">
                                Un compte administrateur a été créé pour vous. Voici vos identifiants de connexion au panel.
                            </p>

                            <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="margin-bottom:20px;">
                                <tr>
                                    <td style="background-color:#f5f8f5;border:1px solid #d5e0d5;border-radius:8px;padding:20px;">
                                        <p style="margin:0 0 8px;font-family:Arial,Helvetica,sans-serif;font-size:12px;letter-spacing:0.08em;text-transform:uppercase;color:#7a8a7a;">
                                            Email
                                        </p>
                                        <p style="margin:0 0 16px;font-family:Arial,Helvetica,sans-serif;font-size:16px;font-weight:700;color:#1a2e1a;">
                                            {{ $user->email }}
                                        </p>
                                        <p style="margin:0 0 8px;font-family:Arial,Helvetica,sans-serif;font-size:12px;letter-spacing:0.08em;text-transform:uppercase;color:#7a8a7a;">
                                            Mot de passe temporaire
                                        </p>
                                        <p style="margin:0;font-family:'Courier New',Courier,monospace;font-size:20px;font-weight:700;letter-spacing:0.08em;color:#1a2e1a;">
                                            {{ $plainPassword }}
                                        </p>
                                    </td>
                                </tr>
                            </table>

                            <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="margin-bottom:24px;">
                                <tr>
                                    <td align="center">
                                        <a href="{{ $loginUrl }}" style="display:inline-block;background-color:#1a2e1a;color:#f0c14b;text-decoration:none;font-family:Arial,Helvetica,sans-serif;font-size:14px;font-weight:700;padding:14px 28px;border-radius:6px;">
                                            Se connecter au panel
                                        </a>
                                    </td>
                                </tr>
                            </table>

                            <p style="margin:0;font-family:Arial,Helvetica,sans-serif;font-size:14px;line-height:1.6;color:#4a5a4a;">
                                Pour votre sécurité, changez ce mot de passe après votre première connexion.
                                Si vous n’êtes pas à l’origine de cette demande, contactez immédiatement un super administrateur.
                            </p>
                        </td>
                    </tr>

                    <tr>
                        <td style="padding:8px 40px 0;">
                            <div style="height:1px;background-color:#d5e0d5;line-height:1px;font-size:1px;">&nbsp;</div>
                        </td>
                    </tr>

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
