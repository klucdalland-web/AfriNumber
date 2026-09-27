"use client";

// app/condition-utilisation/page.tsx , AfriNumber
import { useUiStore } from "@/store/useUIStore";

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="mt-10 first:mt-0">
      <h2 className="text-[17px] sm:text-[19px] font-semibold tracking-tight text-[var(--foreground)]">
        {title}
      </h2>
      <div className="mt-3 space-y-3 text-[15.5px] sm:text-base leading-relaxed text-[color-mix(in_oklch,var(--foreground)_65%,transparent)]">
        {children}
      </div>
    </div>
  );
}

function List({ items }: { items: string[] }) {
  return (
    <ul className="mt-2 space-y-2">
      {items.map((item) => (
        <li key={item} className="flex gap-2.5">
          <span className="mt-2 h-1.5 w-1.5 flex-shrink-0 rounded-full bg-[color-mix(in_oklch,var(--foreground)_45%,transparent)]" />
          <span>{item}</span>
        </li>
      ))}
    </ul>
  );
}

export default function CguPage() {
  const language = useUiStore((state) => state.language);
  const isFrench = language === "fr";

  const copy = isFrench
    ? {
        eyebrow: "Conditions",
        title: "Conditions générales d'utilisation",
        updated: "Dernière mise à jour : 26 septembre 2026",
        s1Title: "1. Objet",
        s1Body: "Les présentes conditions générales régissent l'accès et l'utilisation de la plateforme AfriNumber permettant l'achat, la gestion et l'utilisation de numéros internationaux payables en Mobile Money.",
        s2Title: "2. Éligibilité et KYC",
        s2Body: "L'accès aux services requiert la création d'un compte valide et la soumission des justificatifs requis conformément aux réglementations de télécommunications applicables.",
        s3Title: "3. Modalités de paiement",
        s3Body: "Les transactions sont effectuées en monnaie locale via les passerelles Mobile Money partenaires (MTN MoMo, Airtel Money, Mvola). Les forfaits sont activés dès confirmation du paiement par l'opérateur.",
        s4Title: "4. Usage interdit",
        s4Body: "Il est strictement interdit d'utiliser les numéros AfriNumber à des fins d'activités illégales, de spam, d'usurpation d'identité ou de contournement frauduleux. Tout compte contrevenant sera suspendu immédiatement.",
        s5Title: "5. Contact & Réclamations",
        s5Body: "Pour toute question ou réclamation relative à l'exécution du service, écrivez à contact@afrinumber.com.",
      }
    : {
        eyebrow: "Terms",
        title: "Terms of Service",
        updated: "Last updated: September 26, 2026",
        s1Title: "1. Scope",
        s1Body: "These terms govern the access and use of the AfriNumber platform for acquiring, managing, and operating international virtual phone numbers paid via Mobile Money.",
        s2Title: "2. Eligibility & KYC Verification",
        s2Body: "Access to services requires creating an authenticated account and supplying regulatory verification documents in line with international telecom standards.",
        s3Title: "3. Payment Terms",
        s3Body: "Transactions are executed in local currency via authorized Mobile Money networks (MTN MoMo, Airtel Money, Mvola). Number plans are provisioned immediately upon provider confirmation.",
        s4Title: "4. Prohibited Uses",
        s4Body: "AfriNumber services may not be used for fraudulent activities, unauthorized spamming, harassment, or spoofing. Violations result in immediate suspension and notification of relevant authorities.",
        s5Title: "5. Inquiries & Support",
        s5Body: "For questions or concerns regarding our terms, reach out anytime at contact@afrinumber.com.",
      };

  return (
    <main className="w-full bg-gradient-page min-h-screen text-[var(--foreground)] section-padding pt-28 sm:pt-36">
      <div className="section-container">
        {/* En-tête uniforme */}
        <header className="section-header">
          <span className="section-eyebrow">
            <span className="h-1.5 w-1.5 rounded-full bg-current" />
            {copy.eyebrow}
          </span>
          <h1 className="section-title">
            {copy.title}
          </h1>
          <p className="mt-3 text-[13.5px] text-[color-mix(in_oklch,var(--foreground)_50%,transparent)]">
            {copy.updated}
          </p>
        </header>

        <article className="mx-auto mt-12 w-full max-w-4xl rounded-[1.75rem] border border-[color-mix(in_oklch,var(--foreground)_10%,transparent)] bg-[color-mix(in_oklch,var(--foreground)_3.5%,var(--background))] px-6 py-8 sm:mt-16 sm:px-12 sm:py-12 lg:px-16 shadow-sm">
          <Section title={copy.s1Title}>
            <p>{copy.s1Body}</p>
          </Section>

          <Section title={copy.s2Title}>
            <p>{copy.s2Body}</p>
          </Section>

          <Section title={copy.s3Title}>
            <p>{copy.s3Body}</p>
          </Section>

          <Section title={copy.s4Title}>
            <p>{copy.s4Body}</p>
          </Section>

          <Section title={copy.s5Title}>
            <p>{copy.s5Body}</p>
          </Section>
        </article>
      </div>
    </main>
  );
}