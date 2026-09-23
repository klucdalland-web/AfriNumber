<?php

test('unauthenticated users receive a json unauthorized response', function () {
    $response = $this->getJson('/api/v1/user');

    $response->assertUnauthorized()
        ->assertJson(['message' => 'Unauthenticated.']);
});

test('unauthenticated users without an accept json header receive unauthorized', function () {
    $response = $this->get('/api/v1/user');

    $response->assertUnauthorized()
        ->assertJson(['message' => 'Unauthenticated.']);
});
