"use client";
// Coordonnées de contact et liens externes à valider avant publication.

import Link from "next/link";
import { useUiStore } from "@/store/useUIStore";
import Image from "next/image";

function IconApple() {
  return (
    <svg viewBox="0 0 24 24" fill="currentColor" className="h-5 w-5" aria-hidden="true">
      <path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.1.8 1.21-.24 2.37-.93 3.66-.84 1.55.13 2.72.74 3.5 1.8-3.2 1.92-2.44 6.14.49 7.32-.59 1.56-1.36 3.1-2.75 3.91ZM12.05 7.25C11.9 4.93 13.78 3.02 16 2.8c.31 2.7-2.44 4.7-3.95 4.45Z" />
    </svg>
  );
}

function IconPlayStore() {
  return (
    <svg viewBox="0 0 24 24" fill="none" className="h-5 w-5" aria-hidden="true">
      <path d="M3.5 3.8 13.2 12 3.5 20.2a1.8 1.8 0 0 1-.5-1.3V5.1c0-.5.2-1 .5-1.3Z" fill="#34A853" />
      <path d="m13.2 12 3.1-2.6 3.7 2.1c.8.5.8 1.5 0 2l-3.7 2.1-3.1-2.6Z" fill="#FBBC04" />
      <path d="m3.5 3.8 9.7 8.2 3.1-2.6-10-5.7c-1-.6-2-.4-2.8.1Z" fill="#4285F4" />
      <path d="m3.5 20.2 9.7-8.2 3.1 2.6-10 5.7c-1 .6-2 .4-2.8-.1Z" fill="#EA4335" />
    </svg>
  );
}

export default function Footer() {
  const language = useUiStore((state) => state.language);
  const isFrench = language === "fr";

  const c = isFrench
    ? {
        tagline: "Solution d'inclusion numérique pour les entrepreneurs d'Afrique.",
        productTitle: "Produit",
        productLinks: ["Fonctionnalité", "Numéros internationaux", "SMS & traduction IA", "Paiement Mobile Money", "Mode Zéro Data", "Sécurité & KYC"],
        companyTitle: "Entreprise",
        companyLinks: ["À propos", "Comment ça marche", "Pour qui", "Impact"],
        newsletterTitle: "Restez informé",
        newsletterBody: "Les nouveautés AfriNumber, chaque mois.",
        newsletterUnavailable: "Inscription bientôt disponible.",
        storesTitle: "Bientôt sur vos stores",
        storesBody: "L'application AfriNumber sera disponible prochainement sur Android et iOS.",
        faqButton: "Consulter la FAQ",
        paymentsLine: "Paiements locaux sécurisés via MTN MoMo, Airtel Money & Mvola.",
        stackLine: "Propulsé par Laravel, Supabase, Twilio & OpenAI.",
        legal: ["Mentions légales", "Politique de confidentialité", "CGU","FAQ"],
        rights: "Développé pour le Hackathon. Tous droits réservés.",
      }
    : {
        tagline: "Digital inclusion for African entrepreneurs.",
        productTitle: "Product",
        productLinks: ["Features", "International numbers", "SMS & AI translation", "Mobile Money payment", "Zero Data mode", "Security & KYC"],
        companyTitle: "Company",
        companyLinks: ["About", "How it works", "Who it's for", "Impact"],
        newsletterTitle: "Stay in the loop",
        newsletterBody: "Get a monthly selection of AfriNumber updates.",
        newsletterUnavailable: "Sign-ups are coming soon.",
        storesTitle: "Coming soon to your app stores",
        storesBody: "The AfriNumber app will soon be available on Android and iOS.",
        faqButton: "Visit the FAQ",
        paymentsLine: "Secure local payments via MTN MoMo, Airtel Money & Mvola.",
        stackLine: "Powered by Laravel, Supabase, Twilio & OpenAI.",
        legal: ["Legal notice", "Privacy policy", "Terms of service","FAQ"],
        rights: "Built for the Hackathon. All rights reserved.",
      };

  const linkHref = (label: string) => {
    if (label === 'Fonctionnalité' || label === 'Features') return '/#fonctionnalite';
    if (label === "À propos" || label === "About") return "/#aboutus";
    if (label === "Comment ça marche" || label === "How it works") return "/#commentcamarche";
    if (label === "Impact") return "/#aboutus";
    if (label === "FAQ") return "/faq";
    if (label === "Mentions légales" || label === "Legal notice") return "/informationlegal";
    if (label === "Politique de confidentialité" || label === "Privacy policy") return "/politiqueconfidentialite";
    if (label === "CGU" || label === "Terms of service") return "/condition-utilisation";
    return "/#produit";
  };

  const theme = useUiStore((state) => state.theme);
  return (
    <footer className="relative border-t border-[color-mix(in_oklch,var(--foreground)_10%,transparent)] bg-[var(--background)]">
      <div className="mx-auto w-full max-w-7xl px-4 py-12 sm:px-6 sm:py-16 lg:px-8 lg:py-20">
        <div className="grid grid-cols-1 gap-12 sm:grid-cols-2 lg:grid-cols-[1.3fr_0.9fr_0.9fr] lg:gap-8">
          {/* Identité */}
          <div>
            <div className="group flex items-center gap-2 text-[17px] font-semibold tracking-tight text-[var(--foreground)]">
              {theme === "dark" ? (
                <Image src="/images/logo-afrika-white.png" alt="AfriNumber" width={50} height={50} className="transition-transform duration-300 group-hover:rotate-6" />
              ) : (
                <Image src="/images/logo-afrika.png" alt="AfriNumber" width={50} height={50} className="transition-transform duration-300 group-hover:rotate-6" />
              )}
              <span>AfriNumber</span>
            </div>

            <p className="mt-3 max-w-xs text-[13.5px] leading-relaxed text-[color-mix(in_oklch,var(--foreground)_60%,transparent)]">
              {c.tagline}
            </p>
          </div>

          {/* Produit */}
          <div>
            <h2 className="text-[13px] uppercase tracking-[0.14em] font-medium text-[color-mix(in_oklch,var(--foreground)_45%,transparent)]">
              {c.productTitle}
            </h2>
            <ul className="mt-4 flex flex-col gap-2.5">
              {c.productLinks.map((link) => (
                <li key={link}>
                  <Link
                    href={linkHref(link)}
                    className="inline-block text-[13.5px] text-[color-mix(in_oklch,var(--foreground)_65%,transparent)] transition-all duration-200 ease-out hover:text-[var(--foreground)] hover:translate-x-1"
                  >
                    {link}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Entreprise */}
          <div>
            <h2 className="text-[13px] uppercase tracking-[0.14em] font-medium text-[color-mix(in_oklch,var(--foreground)_45%,transparent)]">
              {c.companyTitle}
            </h2>
            <ul className="mt-4 flex flex-col gap-2.5">
              {c.companyLinks.map((link) => (
                <li key={link}>
                  <Link
                    href={linkHref(link)}
                    className="inline-block text-[13.5px] text-[color-mix(in_oklch,var(--foreground)_65%,transparent)] transition-all duration-200 ease-out hover:text-[var(--foreground)] hover:translate-x-1"
                  >
                    {link}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        </div>

        {/* Disponibilité des applications */}
        <div id="telechargement" className="mt-14 flex flex-col gap-5 border-t border-[color-mix(in_oklch,var(--foreground)_10%,transparent)] pt-10 scroll-mt-24 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <p className="text-[15px] font-semibold tracking-tight text-[var(--foreground)]">{c.storesTitle}</p>
            <p className="mt-1 max-w-xl text-[13px] leading-relaxed text-[color-mix(in_oklch,var(--foreground)_55%,transparent)]">
              {c.storesBody}
            </p>
          </div>
          <div role="group" className="flex flex-wrap gap-3" aria-label={c.storesTitle}>
            <div className="interactive-btn inline-flex items-center gap-2 rounded-xl border border-[color-mix(in_oklch,var(--foreground)_14%,transparent)] bg-[color-mix(in_oklch,var(--foreground)_2%,var(--background))] px-4 py-2.5 text-[var(--foreground)] transition-all duration-300 hover:border-[color-mix(in_oklch,var(--foreground)_30%,transparent)] hover:shadow-md">
              <IconApple />
              <span className="text-left leading-tight">
                <span className="block text-[9px] uppercase tracking-wide opacity-55">Apple</span>
                <span className="block text-[13px] font-semibold">App Store</span>
              </span>
            </div>
            <div className="interactive-btn inline-flex items-center gap-2 rounded-xl border border-[color-mix(in_oklch,var(--foreground)_14%,transparent)] bg-[color-mix(in_oklch,var(--foreground)_2%,var(--background))] px-4 py-2.5 text-[var(--foreground)] transition-all duration-300 hover:border-[color-mix(in_oklch,var(--foreground)_30%,transparent)] hover:shadow-md">
              <IconPlayStore />
              <span className="text-left leading-tight">
                <span className="block text-[9px] uppercase tracking-wide opacity-55">Google</span>
                <span className="block text-[13px] font-semibold">Play Store</span>
              </span>
            </div>
          </div>
        </div>

        {/* Newsletter */}
        <div className="mt-14 sm:mt-16 flex flex-col items-center gap-4 border-t border-[color-mix(in_oklch,var(--foreground)_10%,transparent)] pt-10 text-center sm:flex-row sm:justify-between sm:text-left">
          <div>
            <p className="text-[15px] font-semibold tracking-tight text-[var(--foreground)]">{c.newsletterTitle}</p>
            <p className="mt-1 text-[13px] text-[color-mix(in_oklch,var(--foreground)_55%,transparent)]">
              {c.newsletterBody}
            </p>
          </div>

          <p className="shrink-0 rounded-full border border-border px-4 py-2 text-sm text-muted-foreground">{c.newsletterUnavailable}</p>
        </div>

        {/* Rappel fintech & stack */}
        <div className="mt-8 text-center text-[12px] leading-relaxed text-[color-mix(in_oklch,var(--foreground)_45%,transparent)] sm:text-left">
          <p>{c.paymentsLine}</p>
          <p className="mt-0.5">{c.stackLine}</p>
        </div>

        {/* Bas de page */}
        <div className="mt-8 flex flex-col items-center justify-between gap-4 border-t border-[color-mix(in_oklch,var(--foreground)_10%,transparent)] pt-6 text-center sm:flex-row sm:text-left">
          <p className="text-[12px] text-[color-mix(in_oklch,var(--foreground)_50%,transparent)]">
            &copy; {new Date().getFullYear()} AfriNumber. {c.rights}
          </p>
          <nav aria-label={isFrench ? "Informations légales" : "Legal information"} className="flex flex-wrap items-center justify-center gap-x-5 gap-y-1.5">
            {c.legal.map((item) => (
              <Link
                key={item}
                href={linkHref(item)}
                className="text-[12px] text-[color-mix(in_oklch,var(--foreground)_50%,transparent)] transition-colors duration-200 ease-out hover:text-[var(--foreground)]"
              >
                {item}
              </Link>
            ))}
          </nav>
        </div>
      </div>
    </footer>
  );
}
