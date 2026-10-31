<?php

namespace App\Support;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\ValidationException;

final class ValidatesWithFormRequest
{
    /**
     * @param  class-string<FormRequest>  $requestClass
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     *
     * @throws ValidationException
     */
    public static function validated(string $requestClass, array $data, mixed $routeParameter = null, string $routeParameterName = 'record'): array
    {
        /** @var FormRequest $formRequest */
        $formRequest = $requestClass::createFrom(request());
        $formRequest->replace($data);
        $formRequest->setContainer(app())->setRedirector(app('redirect'));
        $formRequest->setUserResolver(fn () => auth()->user());

        if ($routeParameter !== null) {
            $route = request()->route();

            if ($route !== null) {
                $route->setParameter($routeParameterName, $routeParameter);
            }
        }

        $formRequest->validateResolved();

        return $formRequest->validated();
    }
}
