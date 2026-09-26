import Link from "next/link";
import { routes } from "@/config/routes";
import { buttonVariants } from "@/components/ui/button";

export default function HomePage() {
  return (
    <div className="mx-auto flex w-full max-w-5xl flex-1 flex-col justify-center gap-8 px-4 py-16">
      <div className="max-w-xl space-y-4">
        <p className="text-sm font-medium uppercase tracking-wide text-muted-foreground">
          AfriNumber
        </p>
        <h1 className="text-4xl font-semibold tracking-tight">
          Identité numérique, simple et claire.
        </h1>
        <p className="text-lg text-muted-foreground">
          Architecture Next.js prête : routes typées, shadcn/ui, et layouts
          séparés public / app.
        </p>
      </div>

      <div>
        <Link href={routes.dashboard} className={buttonVariants()}>
          Voir le dashboard
        </Link>
      </div>
    </div>
  );
}
