"use client";

import { useUiStore } from "@/store/useUIStore";

type Category = {
  title: string;
  icon: React.ReactNode;
  features: string[];
  span?: "wide" | "normal";
};

const iconProps = {
  width: 18,
  height: 18,
  viewBox: "0 0 24 24",
  fill: "none",
  stroke: "currentColor",
  strokeWidth: 1.6,
  strokeLinecap: "round" as const,
  strokeLinejoin: "round" as const,
};

const categories: Category[] = [
  {
    title: "Numéros internationaux",
    span: "wide",
    icon: (
      <svg {...iconProps}>
        <circle cx="12" cy="12" r="9" />
        <path d="M3 12h18" />
        <path d="M12 3c2.5 2.6 3.8 5.7 3.8 9s-1.3 6.4-3.8 9c-2.5-2.6-3.8-5.7-3.8-9s1.3-6.4 3.8-9Z" />
      </svg>
    ),
    features: ["Choisir un pays", "Obtenir un numéro", "Gérer son numéro"],
  },
  {
    title: "SMS",
    icon: (
      <svg {...iconProps}>
        <path d="M21 15a2 2 0 0 1-2 2H8l-5 4V6a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v9Z" />
        <path d="M7 9h10M7 12.5h6" />
      </svg>
    ),
    features: ["Recevoir des SMS", "Consulter les messages", "Traduction IA"],
  },
  {
    title: "Paiement",
    icon: (
      <svg {...iconProps}>
        <rect x="3" y="6" width="18" height="13" rx="2.2" />
        <path d="M3 10.5h18" />
        <path d="M7 14.5h4" />
      </svg>
    ),
    features: ["MVola", "Airtel Money", "MTN MoMo"],
  },
  {
    title: "Connectivité",
    icon: (
      <svg {...iconProps}>
        <path d="M5 12.5a10.4 10.4 0 0 1 14 0" />
        <path d="M8.2 16a5.8 5.8 0 0 1 7.6 0" />
        <path d="M11.5 19.3h1" />
        <path d="M3 5l18 15" />
      </svg>
    ),
    features: ["Mode Zéro Data", "Renvoi d'appel GSM"],
  },
  {
    title: "Sécurité",
    icon: (
      <svg {...iconProps}>
        <path d="M12 3.5 5 6.2v5.4c0 4.6 2.9 7.8 7 9.1 4.1-1.3 7-4.5 7-9.1V6.2L12 3.5Z" />
        <path d="m9.2 12.3 2 2 3.6-4" />
      </svg>
    ),
    features: ["KYC", "Protection du compte", "Antifraude"],
  },
];

export default function Produit() {
  const language = useUiStore((state) => state.language);
  const isFrench = language === "fr";
  const copy = isFrench
    ? {
        eyebrow: "Produit",
        title: "Tout ce qu'il faut pour exister à l'international",
        description: "Depuis une seule application : obtenez un numéro, recevez vos messages, encaissez en Mobile Money et restez protégé, même sans connexion stable.",
        categories: [
          { title: "Numéros internationaux", features: ["Choisir un pays", "Obtenir un numéro", "Gérer son numéro"] },
          { title: "SMS", features: ["Recevoir des SMS", "Consulter les messages", "Traduction IA"] },
          { title: "Paiement", features: ["MVola", "Airtel Money", "MTN MoMo"] },
          { title: "Connectivité", features: ["Mode Zéro Data", "Renvoi d'appel GSM"] },
          { title: "Sécurité", features: ["KYC", "Protection du compte", "Antifraude"] },
        ],
      }
    : {
        eyebrow: "Product",
        title: "Everything you need to go global",
        description: "From one simple app: get a number, receive messages, collect payments through Mobile Money, and stay protected, even with an unstable connection.",
        categories: [
          { title: "International numbers", features: ["Choose a country", "Get a number", "Manage your number"] },
          { title: "SMS", features: ["Receive SMS", "Read your messages", "AI translation"] },
          { title: "Payments", features: ["MVola", "Airtel Money", "MTN MoMo"] },
          { title: "Connectivity", features: ["Zero-data mode", "GSM call forwarding"] },
          { title: "Security", features: ["KYC", "Account protection", "Fraud prevention"] },
        ],
      };
  const localizedCategories = categories.map((category, index) => ({
    ...category,
    ...copy.categories[index],
  }));

  return (
    <section id="produit" className="relative overflow-hidden section-padding">
      <div className="section-container">
        {/* En-tête uniforme */}
        <div className="section-header">
          <span className="section-eyebrow">
            <span className="h-1.5 w-1.5 rounded-full bg-current" />
            {copy.eyebrow}
          </span>
          <h2 className="section-title">
            {copy.title}
          </h2>
          <p className="section-description">
            {copy.description}
          </p>
        </div>

        {/* Grille bento avec animations fluides */}
        <div className="mt-14 grid grid-cols-1 gap-5 md:grid-cols-2 xl:grid-cols-3 sm:gap-6">
          {localizedCategories.map((cat, i) => (
            <div
              key={cat.title}
              className={`group relative min-h-[220px] overflow-hidden rounded-[1.75rem] border border-[color-mix(in_oklch,var(--foreground)_10%,transparent)] bg-[color-mix(in_oklch,var(--foreground)_3.5%,var(--background))] p-7 sm:p-8 transition-all duration-300 ease-out hover:-translate-y-1.5 hover:border-[color-mix(in_oklch,var(--foreground)_25%,transparent)] hover:bg-[color-mix(in_oklch,var(--foreground)_6%,var(--background))] hover:shadow-[0_24px_48px_-20px_rgba(0,0,0,0.2)] ${
                cat.span === "wide" ? "xl:col-span-2" : "xl:col-span-1"
              }`}
            >
              {/* Numéro décoratif en filigrane */}
              <span className="pointer-events-none absolute -right-2 -top-4 text-[5.5rem] font-semibold leading-none text-[color-mix(in_oklch,var(--foreground)_4%,transparent)] transition-all duration-300 group-hover:text-[color-mix(in_oklch,var(--foreground)_9%,transparent)] group-hover:scale-105">
                {String(i + 1).padStart(2, "0")}
              </span>

              <div className="relative flex items-center gap-3">
                <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full border border-[color-mix(in_oklch,var(--foreground)_14%,transparent)] bg-[var(--background)] text-[var(--foreground)] transition-all duration-300 group-hover:scale-110 group-hover:bg-[var(--foreground)] group-hover:text-[var(--background)]">
                  {cat.icon}
                </div>
                <span className="text-[12px] font-medium text-[color-mix(in_oklch,var(--foreground)_40%,transparent)]">
                  {String(i + 1).padStart(2, "0")}
                </span>
              </div>

              <h3 className="relative mt-6 text-[17px] font-semibold tracking-tight transition-colors duration-200">
                {cat.title}
              </h3>

              <ul className="relative mt-4 space-y-2.5">
                {cat.features.map((feature) => (
                  <li
                    key={feature}
                    className="flex items-center gap-2.5 text-[13.5px] text-[color-mix(in_oklch,var(--foreground)_62%,transparent)] transition-colors duration-200 group-hover:text-[color-mix(in_oklch,var(--foreground)_85%,transparent)]"
                  >
                    <span className="h-1.5 w-1.5 shrink-0 rounded-full bg-[color-mix(in_oklch,var(--foreground)_45%,transparent)] transition-colors duration-200 group-hover:bg-[var(--foreground)]" />
                    {feature}
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}