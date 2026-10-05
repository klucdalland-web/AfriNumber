<?php

namespace Database\Seeders;

use App\Models\Continent;
use App\Models\Pays;
use Illuminate\Database\Seeder;

class PaysSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $afriqueId = Continent::query()->where('code', 'AF')->value('id');

        if ($afriqueId === null) {
            return;
        }

        $pays = [
            ['label' => 'Afrique du Sud', 'code' => 'ZA', 'indicatif' => '+27', 'timezone' => 'Africa/Johannesburg'],
            ['label' => 'Algérie', 'code' => 'DZ', 'indicatif' => '+213', 'timezone' => 'Africa/Algiers'],
            ['label' => 'Angola', 'code' => 'AO', 'indicatif' => '+244', 'timezone' => 'Africa/Luanda'],
            ['label' => 'Bénin', 'code' => 'BJ', 'indicatif' => '+229', 'timezone' => 'Africa/Porto-Novo'],
            ['label' => 'Botswana', 'code' => 'BW', 'indicatif' => '+267', 'timezone' => 'Africa/Gaborone'],
            ['label' => 'Burkina Faso', 'code' => 'BF', 'indicatif' => '+226', 'timezone' => 'Africa/Ouagadougou'],
            ['label' => 'Burundi', 'code' => 'BI', 'indicatif' => '+257', 'timezone' => 'Africa/Bujumbura'],
            ['label' => 'Cameroun', 'code' => 'CM', 'indicatif' => '+237', 'timezone' => 'Africa/Douala'],
            ['label' => 'Cap-Vert', 'code' => 'CV', 'indicatif' => '+238', 'timezone' => 'Atlantic/Cape_Verde'],
            ['label' => 'Comores', 'code' => 'KM', 'indicatif' => '+269', 'timezone' => 'Indian/Comoro'],
            ['label' => 'Congo', 'code' => 'CG', 'indicatif' => '+242', 'timezone' => 'Africa/Brazzaville'],
            ['label' => 'Côte d\'Ivoire', 'code' => 'CI', 'indicatif' => '+225', 'timezone' => 'Africa/Abidjan'],
            ['label' => 'Djibouti', 'code' => 'DJ', 'indicatif' => '+253', 'timezone' => 'Africa/Djibouti'],
            ['label' => 'Égypte', 'code' => 'EG', 'indicatif' => '+20', 'timezone' => 'Africa/Cairo'],
            ['label' => 'Érythrée', 'code' => 'ER', 'indicatif' => '+291', 'timezone' => 'Africa/Asmara'],
            ['label' => 'Eswatini', 'code' => 'SZ', 'indicatif' => '+268', 'timezone' => 'Africa/Mbabane'],
            ['label' => 'Éthiopie', 'code' => 'ET', 'indicatif' => '+251', 'timezone' => 'Africa/Addis_Ababa'],
            ['label' => 'Gabon', 'code' => 'GA', 'indicatif' => '+241', 'timezone' => 'Africa/Libreville'],
            ['label' => 'Gambie', 'code' => 'GM', 'indicatif' => '+220', 'timezone' => 'Africa/Banjul'],
            ['label' => 'Ghana', 'code' => 'GH', 'indicatif' => '+233', 'timezone' => 'Africa/Accra'],
            ['label' => 'Guinée', 'code' => 'GN', 'indicatif' => '+224', 'timezone' => 'Africa/Conakry'],
            ['label' => 'Guinée équatoriale', 'code' => 'GQ', 'indicatif' => '+240', 'timezone' => 'Africa/Malabo'],
            ['label' => 'Guinée-Bissau', 'code' => 'GW', 'indicatif' => '+245', 'timezone' => 'Africa/Bissau'],
            ['label' => 'Kenya', 'code' => 'KE', 'indicatif' => '+254', 'timezone' => 'Africa/Nairobi'],
            ['label' => 'Lesotho', 'code' => 'LS', 'indicatif' => '+266', 'timezone' => 'Africa/Maseru'],
            ['label' => 'Libéria', 'code' => 'LR', 'indicatif' => '+231', 'timezone' => 'Africa/Monrovia'],
            ['label' => 'Libye', 'code' => 'LY', 'indicatif' => '+218', 'timezone' => 'Africa/Tripoli'],
            ['label' => 'Madagascar', 'code' => 'MG', 'indicatif' => '+261', 'timezone' => 'Indian/Antananarivo'],
            ['label' => 'Malawi', 'code' => 'MW', 'indicatif' => '+265', 'timezone' => 'Africa/Blantyre'],
            ['label' => 'Mali', 'code' => 'ML', 'indicatif' => '+223', 'timezone' => 'Africa/Bamako'],
            ['label' => 'Maroc', 'code' => 'MA', 'indicatif' => '+212', 'timezone' => 'Africa/Casablanca'],
            ['label' => 'Maurice', 'code' => 'MU', 'indicatif' => '+230', 'timezone' => 'Indian/Mauritius'],
            ['label' => 'Mauritanie', 'code' => 'MR', 'indicatif' => '+222', 'timezone' => 'Africa/Nouakchott'],
            ['label' => 'Mozambique', 'code' => 'MZ', 'indicatif' => '+258', 'timezone' => 'Africa/Maputo'],
            ['label' => 'Namibie', 'code' => 'NA', 'indicatif' => '+264', 'timezone' => 'Africa/Windhoek'],
            ['label' => 'Niger', 'code' => 'NE', 'indicatif' => '+227', 'timezone' => 'Africa/Niamey'],
            ['label' => 'Nigéria', 'code' => 'NG', 'indicatif' => '+234', 'timezone' => 'Africa/Lagos'],
            ['label' => 'Ouganda', 'code' => 'UG', 'indicatif' => '+256', 'timezone' => 'Africa/Kampala'],
            ['label' => 'République centrafricaine', 'code' => 'CF', 'indicatif' => '+236', 'timezone' => 'Africa/Bangui'],
            ['label' => 'République démocratique du Congo', 'code' => 'CD', 'indicatif' => '+243', 'timezone' => 'Africa/Kinshasa'],
            ['label' => 'Rwanda', 'code' => 'RW', 'indicatif' => '+250', 'timezone' => 'Africa/Kigali'],
            ['label' => 'Sao Tomé-et-Principe', 'code' => 'ST', 'indicatif' => '+239', 'timezone' => 'Africa/Sao_Tome'],
            ['label' => 'Sénégal', 'code' => 'SN', 'indicatif' => '+221', 'timezone' => 'Africa/Dakar'],
            ['label' => 'Seychelles', 'code' => 'SC', 'indicatif' => '+248', 'timezone' => 'Indian/Mahe'],
            ['label' => 'Sierra Leone', 'code' => 'SL', 'indicatif' => '+232', 'timezone' => 'Africa/Freetown'],
            ['label' => 'Somalie', 'code' => 'SO', 'indicatif' => '+252', 'timezone' => 'Africa/Mogadishu'],
            ['label' => 'Soudan', 'code' => 'SD', 'indicatif' => '+249', 'timezone' => 'Africa/Khartoum'],
            ['label' => 'Soudan du Sud', 'code' => 'SS', 'indicatif' => '+211', 'timezone' => 'Africa/Juba'],
            ['label' => 'Tanzanie', 'code' => 'TZ', 'indicatif' => '+255', 'timezone' => 'Africa/Dar_es_Salaam'],
            ['label' => 'Tchad', 'code' => 'TD', 'indicatif' => '+235', 'timezone' => 'Africa/Ndjamena'],
            ['label' => 'Togo', 'code' => 'TG', 'indicatif' => '+228', 'timezone' => 'Africa/Lome'],
            ['label' => 'Tunisie', 'code' => 'TN', 'indicatif' => '+216', 'timezone' => 'Africa/Tunis'],
            ['label' => 'Zambie', 'code' => 'ZM', 'indicatif' => '+260', 'timezone' => 'Africa/Lusaka'],
            ['label' => 'Zimbabwe', 'code' => 'ZW', 'indicatif' => '+263', 'timezone' => 'Africa/Harare'],
        ];

        foreach ($pays as $paysData) {
            Pays::query()->updateOrCreate(
                ['code' => $paysData['code']],
                $paysData + [
                    'continent_id' => $afriqueId,
                    'actif' => true,
                ],
            );
        }
    }
}
