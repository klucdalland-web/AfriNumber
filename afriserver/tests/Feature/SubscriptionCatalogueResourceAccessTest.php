<?php

use App\Filament\Resources\Plans\PlanResource;
use App\Filament\Resources\Services\ServiceResource;
use App\Filament\Resources\Subscriptions\SubscriptionResource;
use App\Filament\Resources\Transactions\TransactionResource;
use App\Filament\Resources\TypeTransactions\TypeTransactionResource;
use App\Models\TypeUser;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\PermissionRegistrar;

uses(RefreshDatabase::class);

beforeEach(function (): void {
    Filament::setCurrentPanel(Filament::getPanel('afriNetAdmin'));

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

test('super_admin can open subscription catalogue resources', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('super_admin');

    $this->actingAs($admin);

    expect(ServiceResource::canViewAny())->toBeTrue()
        ->and(PlanResource::canViewAny())->toBeTrue()
        ->and(SubscriptionResource::canViewAny())->toBeTrue()
        ->and(TypeTransactionResource::canViewAny())->toBeTrue()
        ->and(TransactionResource::canViewAny())->toBeTrue();

    $this->get(ServiceResource::getUrl('index'))->assertOk();
    $this->get(PlanResource::getUrl('index'))->assertOk();
    $this->get(SubscriptionResource::getUrl('index'))->assertOk();
    $this->get(TypeTransactionResource::getUrl('index'))->assertOk();
    $this->get(TransactionResource::getUrl('index'))->assertOk();
});

test('gestionnaire can manage subscription catalogue resources', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('gestionnaire');

    $this->actingAs($admin);

    expect(ServiceResource::canViewAny())->toBeTrue()
        ->and(ServiceResource::canCreate())->toBeTrue()
        ->and(PlanResource::canViewAny())->toBeTrue()
        ->and(PlanResource::canCreate())->toBeTrue()
        ->and(SubscriptionResource::canViewAny())->toBeTrue()
        ->and(SubscriptionResource::canCreate())->toBeTrue()
        ->and(TypeTransactionResource::canViewAny())->toBeTrue()
        ->and(TypeTransactionResource::canCreate())->toBeTrue()
        ->and(TransactionResource::canViewAny())->toBeTrue()
        ->and(TransactionResource::canCreate())->toBeTrue();

    $this->get(ServiceResource::getUrl('index'))->assertOk();
    $this->get(PlanResource::getUrl('index'))->assertOk();
    $this->get(SubscriptionResource::getUrl('index'))->assertOk();
    $this->get(TypeTransactionResource::getUrl('index'))->assertOk();
    $this->get(TransactionResource::getUrl('index'))->assertOk();
});

test('operateur cannot open subscription catalogue resources', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('operateur');

    $this->actingAs($admin);

    expect(ServiceResource::canViewAny())->toBeFalse()
        ->and(PlanResource::canViewAny())->toBeFalse()
        ->and(SubscriptionResource::canViewAny())->toBeFalse()
        ->and(TypeTransactionResource::canViewAny())->toBeFalse()
        ->and(TransactionResource::canViewAny())->toBeFalse();

    $this->get(ServiceResource::getUrl('index'))->assertForbidden();
    $this->get(PlanResource::getUrl('index'))->assertForbidden();
    $this->get(SubscriptionResource::getUrl('index'))->assertForbidden();
    $this->get(TypeTransactionResource::getUrl('index'))->assertForbidden();
    $this->get(TransactionResource::getUrl('index'))->assertForbidden();
});
