"use client";

// app/politiqueconfidentialite/page.tsx , AfriNumber
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

export default function PolitiqueDeConfidentialitePage() {
  const language = useUiStore((state) => state.language);
  const isFrench = language === "fr";

  const copy = isFrench
    ? {
        eyebrow: "Vie privée",
        title: "Politique de confidentialité",
        updated: "Dernière mise à jour : 26 septembre 2026",
        s1Title: "1. Données collectées",
        s1Body: "Dans le cadre de l'utilisation de nos services, nous pouvons collecter les informations suivantes :",
        s1Items: [
          "Données d'identification : nom, prénom, numéro de téléphone Mobile Money, adresse e-mail.",
          "Données KYC : pièces d'identité officielles transmises pour la vérification réglementaire des numéros.",
          "Données de communications : métadonnées des SMS et appels (date, heure, indicatif d'origine).",
          "Données techniques : adresse IP, type d'appareil, logs de connexion sécurisés.",
        ],
        s2Title: "2. Utilisation de vos données",
        s2Body: "Vos données sont traitées pour fournir les services de télécommunications, assurer la sécurité des transactions et respecter nos obligations légales anti-fraude.",
        s3Title: "3. Sécurité et Chiffrement",
        s3Body: "Toutes vos données sensibles et documents d'identification sont chiffrés selon les standards de sécurité les plus stricts (AES-256 et TLS 1.3).",
        s4Title: "4. Vos droits",
        s4Body: "Conformément aux lois applicables, vous disposez d'un droit d'accès, de rectification et de suppression de vos données personnelles en contactant contact@afrinumber.com.",
      }
    : {
        eyebrow: "Privacy",
        title: "Privacy Policy",
        updated: "Last updated: September 26, 2026",
        s1Title: "1. Data Collected",
        s1Body: "When using our services, we may collect the following categories of information:",
        s1Items: [
          "Identity details: full name, Mobile Money phone number, email address.",
          "KYC information: official identification documents submitted for regulatory compliance.",
          "Communication logs: metadata of calls and SMS (timestamps, origin country codes).",
          "Technical telemetry: IP address, device specifications, secure authentication logs.",
        ],
        s2Title: "2. How We Use Your Data",
        s2Body: "Your information is used strictly to provide telecommunications services, secure financial transactions, and comply with international anti-fraud obligations.",
        s3Title: "3. Security & Encryption",
        s3Body: "All sensitive information and identity verification files are encrypted following state-of-the-art security standards (AES-256 and TLS 1.3).",
        s4Title: "4. Your Rights",
        s4Body: "In accordance with privacy regulations, you have the right to access, rectify, or request deletion of your personal data by writing to contact@afrinumber.com.",
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
            <List items={copy.s1Items} />
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
        </article>
      </div>
    </main>
  );
}