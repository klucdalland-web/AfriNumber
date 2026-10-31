<?php

use App\Http\Requests\Admin\StoreFraisTransactionRequest;
use App\Models\FraisTransaction;
use App\Models\Pays;
use App\Models\TypeTransaction;
use App\Models\TypeUser;
use App\Models\User;
use App\Support\PanelPermission;
use App\Support\ValidatesWithFormRequest;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Validation\ValidationException;
use Spatie\Permission\PermissionRegistrar;

uses(RefreshDatabase::class);

beforeEach(function (): void {
    TypeUser::query()->updateOrCreate(
        ['code' => 'admin'],
        [
            'label' => 'Administrateur',
            'description' => 'Administrateur système',
            'actif' => true,
        ],
    );

    $this->seed(RolesAndPermissionsSeeder::class);
    app()[PermissionRegistrar::class]->forgetCachedPermissions();
});

function createTypeTransaction(string $code = 'transfer_w2w'): TypeTransaction
{
    return TypeTransaction::query()->create([
        'code' => $code,
        'label' => $code,
        'description' => null,
        'actif' => true,
        'sort_order' => 1,
    ]);
}

function actingAdminWithFraisPermission(): User
{
    $admin = User::factory()->admin()->create();
    $admin->givePermissionTo(PanelPermission::FRAIS_GERER);
    app()[PermissionRegistrar::class]->forgetCachedPermissions();

    test()->actingAs($admin);

    return $admin;
}

describe('pourOperation', function (): void {
    it('priorise la règle du pays sur la règle par défaut', function (): void {
        $type = createTypeTransaction();
        $pays = Pays::factory()->create();

        FraisTransaction::factory()->create([
            'type_transaction_id' => $type->id,
            'pays_id' => null,
            'taux_pourcentage' => '1.0000',
            'statut' => FraisTransaction::STATUT_ACTIF,
        ]);

        $paysRule = FraisTransaction::factory()->create([
            'type_transaction_id' => $type->id,
            'pays_id' => $pays->id,
            'taux_pourcentage' => '2.5000',
            'statut' => FraisTransaction::STATUT_ACTIF,
        ]);

        expect(FraisTransaction::pourOperation($type->id, $pays->id)?->is($paysRule))->toBeTrue();
    });

    it('replie sur la regle par defaut lorsque le pays n a pas de regle', function (): void {
        $type = createTypeTransaction('transfer_w2e');
        $pays = Pays::factory()->create();

        $default = FraisTransaction::factory()->create([
            'type_transaction_id' => $type->id,
            'pays_id' => null,
            'taux_pourcentage' => '1.5000',
            'statut' => FraisTransaction::STATUT_ACTIF,
        ]);

        expect(FraisTransaction::pourOperation($type->id, $pays->id)?->is($default))->toBeTrue();
    });

    it('ignore les regles inactives', function (): void {
        $type = createTypeTransaction('fee');
        $pays = Pays::factory()->create();

        FraisTransaction::factory()->inactif()->create([
            'type_transaction_id' => $type->id,
            'pays_id' => $pays->id,
            'taux_pourcentage' => '5.0000',
        ]);

        FraisTransaction::factory()->inactif()->create([
            'type_transaction_id' => $type->id,
            'pays_id' => null,
            'taux_pourcentage' => '1.0000',
        ]);

        expect(FraisTransaction::pourOperation($type->id, $pays->id))->toBeNull();
    });

    it('retourne null lorsqu aucune regle active n existe', function (): void {
        $type = createTypeTransaction('refund');

        expect(FraisTransaction::pourOperation($type->id, null))->toBeNull();
    });
});

describe('validation', function (): void {
    it('refuse un montant_max inferieur au montant_min', function (): void {
        actingAdminWithFraisPermission();
        $type = createTypeTransaction();

        try {
            ValidatesWithFormRequest::validated(StoreFraisTransactionRequest::class, [
                'type_transaction_id' => $type->id,
                'pays_id' => null,
                'montant_fixe' => '0',
                'taux_pourcentage' => '1',
                'montant_min' => '1',
                'montant_max' => '0.5',
                'statut' => FraisTransaction::STATUT_ACTIF,
            ]);
            expect(false)->toBeTrue();
        } catch (ValidationException $e) {
            expect($e->errors())->toHaveKey('montant_max');
        }
    });

    it('refuse un doublon de regle par defaut pour le meme type', function (): void {
        actingAdminWithFraisPermission();
        $type = createTypeTransaction();

        FraisTransaction::factory()->create([
            'type_transaction_id' => $type->id,
            'pays_id' => null,
        ]);

        try {
            ValidatesWithFormRequest::validated(StoreFraisTransactionRequest::class, [
                'type_transaction_id' => $type->id,
                'pays_id' => null,
                'montant_fixe' => '0',
                'taux_pourcentage' => '1',
                'montant_min' => '0.10',
                'montant_max' => null,
                'statut' => FraisTransaction::STATUT_ACTIF,
            ]);
            expect(false)->toBeTrue();
        } catch (ValidationException $e) {
            expect($e->errors())->toHaveKey('pays_id')
                ->and($e->errors()['pays_id'][0])->toContain('règle par défaut');
        }
    });
});
