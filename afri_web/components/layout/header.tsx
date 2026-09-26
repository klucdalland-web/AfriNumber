import Link from "next/link";
import { routes } from "@/config/routes";

export function Header() {
  return (
    <header className="border-b border-border bg-background/80 backdrop-blur">
      <div className="mx-auto flex h-14 max-w-5xl items-center justify-between px-4">
        <Link href={routes.home} className="text-lg font-semibold tracking-tight">
          AfriNumber
        </Link>
        <nav className="flex items-center gap-3 text-sm">
          <Link
            href={routes.dashboard}
            className="text-muted-foreground hover:text-foreground"
          >
            Dashboard
          </Link>
        </nav>
      </div>
    </header>
  );
}
