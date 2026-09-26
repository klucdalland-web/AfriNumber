/**
 * Carte centrale des routes — source de vérité pour les URLs.
 *
 * Usage :
 *   import { routes } from "@/config/routes";
 *   <Link href={routes.dashboard}>…</Link>
 */

export const routes = {
  home: "/",
  dashboard: "/dashboard",
} as const;

export type AppRoute = (typeof routes)[keyof typeof routes];
