import Link from "next/link";
import { routes } from "@/config/routes";

export default function NotFound() {
  return (
    <div className="flex flex-1 flex-col items-center justify-center gap-4 px-4 py-24 text-center">
      <h1 className="text-2xl font-semibold">Page introuvable</h1>
      <p className="text-zinc-500">Cette URL n’existe pas dans AfriNumber.</p>
      <Link
        href={routes.home}
        className="text-sm font-medium text-emerald-700 hover:underline"
      >
        Retour à l’accueil
      </Link>
    </div>
  );
}
