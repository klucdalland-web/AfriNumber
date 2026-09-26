import Link from "next/link";
import { routes } from "@/config/routes";

export function AppSidebar() {
  return (
    <aside className="flex w-56 flex-col border-r border-border bg-background p-4">
      <Link href={routes.dashboard} className="mb-8 text-lg font-semibold">
        AfriNumber
      </Link>

      <nav className="flex flex-1 flex-col gap-1 text-sm">
        <Link
          href={routes.dashboard}
          className="rounded-lg px-3 py-2 font-medium text-foreground hover:bg-muted"
        >
          Tableau de bord
        </Link>
        <Link
          href={routes.home}
          className="rounded-lg px-3 py-2 text-muted-foreground hover:bg-muted hover:text-foreground"
        >
          Accueil
        </Link>
      </nav>
    </aside>
  );
}
