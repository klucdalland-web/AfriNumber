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
            ['label' => 'Afrique du Sud', 'code' => 'ZA', 'indicatif' => '+27'],
            ['label' => 'Algérie', 'code' => 'DZ', 'indicatif' => '+213'],
            ['label' => 'Angola', 'code' => 'AO', 'indicatif' => '+244'],
            ['label' => 'Bénin', 'code' => 'BJ', 'indicatif' => '+229'],
            ['label' => 'Botswana', 'code' => 'BW', 'indicatif' => '+267'],
            ['label' => 'Burkina Faso', 'code' => 'BF', 'indicatif' => '+226'],
            ['label' => 'Burundi', 'code' => 'BI', 'indicatif' => '+257'],
            ['label' => 'Cameroun', 'code' => 'CM', 'indicatif' => '+237'],
            ['label' => 'Cap-Vert', 'code' => 'CV', 'indicatif' => '+238'],
            ['label' => 'Comores', 'code' => 'KM', 'indicatif' => '+269'],
            ['label' => 'Congo', 'code' => 'CG', 'indicatif' => '+242'],
            ['label' => 'Côte d\'Ivoire', 'code' => 'CI', 'indicatif' => '+225'],
            ['label' => 'Djibouti', 'code' => 'DJ', 'indicatif' => '+253'],
            ['label' => 'Égypte', 'code' => 'EG', 'indicatif' => '+20'],
            ['label' => 'Érythrée', 'code' => 'ER', 'indicatif' => '+291'],
            ['label' => 'Eswatini', 'code' => 'SZ', 'indicatif' => '+268'],
            ['label' => 'Éthiopie', 'code' => 'ET', 'indicatif' => '+251'],
            ['label' => 'Gabon', 'code' => 'GA', 'indicatif' => '+241'],
            ['label' => 'Gambie', 'code' => 'GM', 'indicatif' => '+220'],
            ['label' => 'Ghana', 'code' => 'GH', 'indicatif' => '+233'],
            ['label' => 'Guinée', 'code' => 'GN', 'indicatif' => '+224'],
            ['label' => 'Guinée équatoriale', 'code' => 'GQ', 'indicatif' => '+240'],
            ['label' => 'Guinée-Bissau', 'code' => 'GW', 'indicatif' => '+245'],
            ['label' => 'Kenya', 'code' => 'KE', 'indicatif' => '+254'],
            ['label' => 'Lesotho', 'code' => 'LS', 'indicatif' => '+266'],
            ['label' => 'Libéria', 'code' => 'LR', 'indicatif' => '+231'],
            ['label' => 'Libye', 'code' => 'LY', 'indicatif' => '+218'],
            ['label' => 'Madagascar', 'code' => 'MG', 'indicatif' => '+261'],
            ['label' => 'Malawi', 'code' => 'MW', 'indicatif' => '+265'],
            ['label' => 'Mali', 'code' => 'ML', 'indicatif' => '+223'],
            ['label' => 'Maroc', 'code' => 'MA', 'indicatif' => '+212'],
            ['label' => 'Maurice', 'code' => 'MU', 'indicatif' => '+230'],
            ['label' => 'Mauritanie', 'code' => 'MR', 'indicatif' => '+222'],
            ['label' => 'Mozambique', 'code' => 'MZ', 'indicatif' => '+258'],
            ['label' => 'Namibie', 'code' => 'NA', 'indicatif' => '+264'],
            ['label' => 'Niger', 'code' => 'NE', 'indicatif' => '+227'],
            ['label' => 'Nigéria', 'code' => 'NG', 'indicatif' => '+234'],
            ['label' => 'Ouganda', 'code' => 'UG', 'indicatif' => '+256'],
            ['label' => 'République centrafricaine', 'code' => 'CF', 'indicatif' => '+236'],
            ['label' => 'République démocratique du Congo', 'code' => 'CD', 'indicatif' => '+243'],
            ['label' => 'Rwanda', 'code' => 'RW', 'indicatif' => '+250'],
            ['label' => 'Sao Tomé-et-Principe', 'code' => 'ST', 'indicatif' => '+239'],
            ['label' => 'Sénégal', 'code' => 'SN', 'indicatif' => '+221'],
            ['label' => 'Seychelles', 'code' => 'SC', 'indicatif' => '+248'],
            ['label' => 'Sierra Leone', 'code' => 'SL', 'indicatif' => '+232'],
            ['label' => 'Somalie', 'code' => 'SO', 'indicatif' => '+252'],
            ['label' => 'Soudan', 'code' => 'SD', 'indicatif' => '+249'],
            ['label' => 'Soudan du Sud', 'code' => 'SS', 'indicatif' => '+211'],
            ['label' => 'Tanzanie', 'code' => 'TZ', 'indicatif' => '+255'],
            ['label' => 'Tchad', 'code' => 'TD', 'indicatif' => '+235'],
            ['label' => 'Togo', 'code' => 'TG', 'indicatif' => '+228'],
            ['label' => 'Tunisie', 'code' => 'TN', 'indicatif' => '+216'],
            ['label' => 'Zambie', 'code' => 'ZM', 'indicatif' => '+260'],
            ['label' => 'Zimbabwe', 'code' => 'ZW', 'indicatif' => '+263'],
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
