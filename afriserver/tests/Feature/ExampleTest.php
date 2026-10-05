<?php

test('the application redirects the root to the admin panel', function () {
    $response = $this->get('/');

    $response->assertRedirect('/afriNetAdmin');
});
