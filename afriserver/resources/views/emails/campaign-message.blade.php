<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $appName }} — {{ $title }}</title>
</head>
@php
    $bg = \App\Support\Brand::color('background', '#F6F4EF');
    $fg = \App\Support\Brand::color('foreground', '#1C1A17');
    $card = \App\Support\Brand::color('card', '#FCFAF7');
    $mutedFg = \App\Support\Brand::color('muted_foreground', '#6B655C');
    $border = \App\Support\Brand::color('border', '#D4CFC4');
    $primary = \App\Support\Brand::color('primary', '#1C1A17');
    $primaryFg = \App\Support\Brand::color('primary_foreground', '#F6F4EF');
@endphp
<body style="margin:0;padding:0;background-color:{{ $bg }};font-family:Arial,Helvetica,sans-serif;">
    <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="background-color:{{ $bg }};padding:40px 16px;">
        <tr>
            <td align="center">
                <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="max-width:520px;background-color:{{ $card }};border-radius:12px;overflow:hidden;border:1px solid {{ $border }};">
                    <tr>
                        <td style="background-color:{{ $primary }};padding:28px 40px;text-align:center;">
                            <img src="{{ $logoBlackUrl }}" alt="{{ $appName }}" width="48" height="48" style="display:block;margin:0 auto 12px;filter:brightness(0) invert(1);">
                            <p style="margin:0;font-size:20px;font-weight:700;color:{{ $primaryFg }};">{{ $appName }}</p>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding:32px 40px;">
                            <p style="margin:0 0 8px;font-size:14px;color:{{ $mutedFg }};">Bonjour {{ $firstName }},</p>
                            <h1 style="margin:0 0 16px;font-size:20px;font-weight:700;color:{{ $fg }};">{{ $title }}</h1>
                            <p style="margin:0;font-size:15px;line-height:1.6;color:{{ $mutedFg }};white-space:pre-wrap;">{{ $body }}</p>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding:0 40px 28px;font-size:12px;color:{{ $mutedFg }};">
                            © {{ $copyrightYear }} {{ $appName }}
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
