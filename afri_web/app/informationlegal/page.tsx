"use client";

// app/informationlegal/page.tsx , AfriNumber
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

export default function MentionsLegalesPage() {
  const language = useUiStore((state) => state.language);
  const isFrench = language === "fr";

  const copy = isFrench
    ? {
        eyebrow: "Informations légales",
        title: "Mentions légales",
        updated: "Dernière mise à jour : 26 septembre 2026",
        s1Title: "1. Éditeur du site",
        s1Body: "Le site AfriNumber est édité par AfriNumber SAS, immatriculée au registre du commerce, dont le siège social est situé à Brazzaville et Antananarivo. Contact : contact@afrinumber.com.",
        s2Title: "2. Hébergement & Infrastructure",
        s2Body: "Le site web est hébergé sur une infrastructure cloud sécurisée de haute disponibilité. Les services applicatifs (numéros virtuels, messagerie, base de données temps réel) s'appuient sur des infrastructures certifiées conformes aux standards internationaux.",
        s3Title: "3. Propriété intellectuelle",
        s3Body: "L'ensemble des éléments présents sur le site AfriNumber (textes, logo, charte graphique, icônes, structure) est la propriété exclusive d'AfriNumber ou de ses partenaires. Toute reproduction sans autorisation préalable est interdite.",
        s4Title: "4. Responsabilité",
        s4Body: "AfriNumber met tout en œuvre pour assurer l'exactitude des informations diffusées sur le site, mais ne saurait être tenu responsable des pannes temporaires de fournisseurs tiers (opérateurs télécom, Mobile Money).",
        s5Title: "5. Droit applicable",
        s5Body: "Les présentes mentions légales sont soumises au droit en vigueur dans les pays où AfriNumber opère (notamment la République du Congo et Madagascar).",
      }
    : {
        eyebrow: "Legal Information",
        title: "Legal Notice",
        updated: "Last updated: September 26, 2026",
        s1Title: "1. Publisher",
        s1Body: "The AfriNumber website is published by AfriNumber SAS, registered in the trade register with operations in Brazzaville and Antananarivo. Contact: contact@afrinumber.com.",
        s2Title: "2. Hosting & Infrastructure",
        s2Body: "The website is hosted on high-availability, secure cloud infrastructure. Core application components (virtual numbers, messaging, real-time database) leverage industry-standard certified services.",
        s3Title: "3. Intellectual Property",
        s3Body: "All materials on the AfriNumber platform (content, branding, graphics, icons, architecture) are the exclusive property of AfriNumber and its partners. Unauthorized reproduction is strictly prohibited.",
        s4Title: "4. Liability",
        s4Body: "AfriNumber strives to provide accurate and uninterrupted service, but cannot be held liable for third-party provider downtime (telecom operators, Mobile Money networks).",
        s5Title: "5. Applicable Law",
        s5Body: "This legal notice is governed by applicable laws in countries where AfriNumber operates (notably Republic of Congo and Madagascar).",
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