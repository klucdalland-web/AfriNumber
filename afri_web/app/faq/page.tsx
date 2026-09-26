"use client";

// app/faq/page.tsx , AfriNumber
import FaqAccordion from "@/components/faqaccordion";
import { useUiStore } from "@/store/useUIStore";

export default function FaqPage() {
  const language = useUiStore((state) => state.language);
  const isFrench = language === "fr";

  const copy = isFrench
    ? {
        eyebrow: "FAQ",
        title: "Questions fréquentes",
        description: "Tout ce qu'il faut savoir sur les numéros internationaux, le paiement en Mobile Money et la sécurité de votre compte.",
      }
    : {
        eyebrow: "FAQ",
        title: "Frequently Asked Questions",
        description: "Everything you need to know about international numbers, Mobile Money payments, and account security.",
      };

  return (
    <main className="w-full bg-gradient-page min-h-screen text-[var(--foreground)] section-padding pt-28 sm:pt-36">
      <div className="section-container">
        <header className="section-header">
          <span className="section-eyebrow">
            <span className="h-1.5 w-1.5 rounded-full bg-current" />
            {copy.eyebrow}
          </span>
          <h1 className="section-title">
            {copy.title}
          </h1>
          <p className="section-description">
            {copy.description}
          </p>
        </header>

        <div className="mx-auto mt-12 w-full max-w-5xl rounded-[1.75rem] border border-[color-mix(in_oklch,var(--foreground)_10%,transparent)] bg-[color-mix(in_oklch,var(--foreground)_3.5%,var(--background))] p-5 sm:mt-16 sm:p-10 lg:p-12 shadow-sm">
          <FaqAccordion />
        </div>
      </div>
    </main>
  );
}