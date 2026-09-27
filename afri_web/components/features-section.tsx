"use client";

import { useUiStore } from "@/store/useUIStore";

function IconPhone() {
  return (
    <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5" strokeWidth={1.5} stroke="currentColor">
      <path
        d="M8.5 4.5 6 5.2c-1 .3-1.6 1.3-1.3 2.3 1 3.6 3 6.9 5.8 9.7 2.8 2.8 6.1 4.8 9.7 5.8 1 .3 2-.3 2.3-1.3l.7-2.5c.3-1-.2-2-1.1-2.4l-2.9-1.2c-.8-.3-1.7-.1-2.3.5l-1 1c-2-1-3.6-2.6-4.6-4.6l1-1c.6-.6.8-1.5.5-2.3L11.4 6.1c-.4-.9-1.4-1.4-2.4-1.1Z"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function IconWallet() {
  return (
    <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5" strokeWidth={1.5} stroke="currentColor">
      <path d="M3.5 7.5A2.5 2.5 0 0 1 6 5h11a1.5 1.5 0 0 1 1.5 1.5v1" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M3.5 7.5v9A2.5 2.5 0 0 0 6 19h12.5A1.5 1.5 0 0 0 20 17.5v-8A1.5 1.5 0 0 0 18.5 8H6a2.5 2.5 0 0 1-2.5-2.5Z" strokeLinecap="round" strokeLinejoin="round" />
      <circle cx="16" cy="13" r="1.2" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function IconChat() {
  return (
    <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5" strokeWidth={1.5} stroke="currentColor">
      <path
        d="M4 12c0-4.1 3.6-7.5 8-7.5s8 3.4 8 7.5-3.6 7.5-8 7.5c-1 0-2-.2-2.9-.5L5 20.5l1.2-3.4C4.8 15.9 4 14 4 12Z"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path d="M9 11.5h.01M12 11.5h.01M15 11.5h.01" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function IconAntenna() {
  return (
    <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5" strokeWidth={1.5} stroke="currentColor">
      <path d="M12 21V10.5" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M9.5 12.8 12 10.5l2.5 2.3" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M7 9.2a7 7 0 0 1 10 0" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M4.3 6.5a10.8 10.8 0 0 1 15.4 0" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function IconTranslate() {
  return (
    <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5" strokeWidth={1.5} stroke="currentColor">
      <path d="M4.5 6h8M8.3 4.3v1.7M6 6c.3 3 2.2 5.3 4.8 6.8M10.5 6c-.6 3.3-2.7 6-5.7 7.7" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M13 20l3.2-8.5L19.5 20" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M14 17.3h4.4" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function IconShield() {
  return (
    <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5" strokeWidth={1.5} stroke="currentColor">
      <path d="M12 3.5 19 6v5.5c0 4.3-2.9 7.6-7 9-4.1-1.4-7-4.7-7-9V6l7-2.5Z" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M9 12.2 11.2 14.4 15.5 9.8" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

export default function FeaturesSection() {
  const language = useUiStore((state) => state.language);
  const isFrench = language === "fr";

  const copy = isFrench
    ? {
        eyebrow: "Fonctionnalités",
        title: "Tout ce qu'il faut pour travailler à l'international",
        description: "Un numéro international, payable en Mobile Money, pensé pour les réalités du réseau africain , connecté ou non.",
        features: [
          {
            icon: <IconPhone />,
            title: "Numéros internationaux",
            description: "Choisissez un numéro dans le pays de votre choix (États-Unis, France, Canada, Royaume-Uni) et gérez-le entièrement depuis l'application.",
          },
          {
            icon: <IconWallet />,
            title: "Paiement Mobile Money",
            description: "Payez directement via MTN MoMo, Airtel Money ou Mvola. Aucune carte bancaire internationale requise, aucune barrière.",
          },
          {
            icon: <IconChat />,
            title: "Gestion des SMS",
            description: "Recevez et consultez vos SMS professionnels en temps réel, où que vous soyez, directement depuis votre tableau de bord.",
          },
          {
            icon: <IconAntenna />,
            title: "Mode Zéro Data",
            description: "Continuez à recevoir vos appels et SMS même sans connexion internet, grâce à un renvoi d'appel GSM direct.",
          },
          {
            icon: <IconTranslate />,
            title: "Traduction IA",
            description: "Vos SMS entrants sont traduits automatiquement dans votre langue en quelques secondes, sans copier-coller externe.",
          },
          {
            icon: <IconShield />,
            title: "Sécurité & KYC",
            description: "Vérification d'identité automatisée et pare-feu antifraude intégré pour protéger votre compte et vos transactions.",
          },
        ],
      }
    : {
        eyebrow: "Features",
        title: "Everything you need to work globally",
        description: "An international number, payable with Mobile Money, designed for African network realities — connected or offline.",
        features: [
          {
            icon: <IconPhone />,
            title: "International Numbers",
            description: "Choose a phone number in your target country (USA, France, Canada, UK) and manage it entirely from your mobile app.",
          },
          {
            icon: <IconWallet />,
            title: "Mobile Money Payments",
            description: "Pay directly using MTN MoMo, Airtel Money, or Mvola. No international credit card required, zero barriers.",
          },
          {
            icon: <IconChat />,
            title: "SMS Management",
            description: "Receive and read your business SMS messages in real-time wherever you are, directly from your dashboard.",
          },
          {
            icon: <IconAntenna />,
            title: "Zero Data Mode",
            description: "Keep receiving calls and SMS messages even without an active internet connection via direct GSM forwarding.",
          },
          {
            icon: <IconTranslate />,
            title: "AI Translation",
            description: "Incoming SMS messages are translated automatically into your language in seconds, with no manual copy-paste.",
          },
          {
            icon: <IconShield />,
            title: "Security & KYC",
            description: "Automated identity verification and integrated anti-fraud firewall to safeguard your account and transactions.",
          },
        ],
      };

  return (
    <section aria-labelledby="features-heading" className="relative overflow-hidden section-padding">
      {/* Texture de fond subtile */}
      <div
        aria-hidden
        className="pointer-events-none absolute inset-0"
        style={{
          backgroundImage:
            "radial-gradient(color-mix(in oklch, var(--foreground) 16%, transparent) 1px, transparent 1px)",
          backgroundSize: "24px 24px",
          maskImage: "radial-gradient(ellipse 65% 55% at 50% 15%, black 30%, transparent 100%)",
          WebkitMaskImage: "radial-gradient(ellipse 65% 55% at 50% 15%, black 30%, transparent 100%)",
        }}
      />

      <div className="relative section-container">
        {/* En-tête uniforme */}
        <div className="section-header">
          <span className="section-eyebrow">
            <span className="h-1.5 w-1.5 rounded-full bg-current" />
            {copy.eyebrow}
          </span>
          <h2 id="features-heading" className="section-title">
            {copy.title}
          </h2>
          <p className="section-description">
            {copy.description}
          </p>
        </div>

        {/* Grille de fonctionnalités avec hover effects */}
        <div className="motion-stagger grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3 sm:gap-6">
          {copy.features.map((f) => (
            <div
              key={f.title}
              className="group relative rounded-[1.75rem] border border-[color-mix(in_oklch,var(--foreground)_10%,transparent)] bg-[color-mix(in_oklch,var(--foreground)_3.5%,var(--background))] p-7 sm:p-8 transition-all duration-300 ease-out hover:-translate-y-1.5 hover:border-[color-mix(in_oklch,var(--foreground)_25%,transparent)] hover:bg-[color-mix(in_oklch,var(--foreground)_6%,var(--background))] hover:shadow-[0_24px_48px_-20px_rgba(0,0,0,0.22)]"
            >
              <div className="flex h-12 w-12 items-center justify-center rounded-full border border-[color-mix(in_oklch,var(--foreground)_14%,transparent)] bg-[var(--background)] text-[var(--foreground)] transition-all duration-300 ease-out group-hover:scale-110 group-hover:bg-[var(--foreground)] group-hover:text-[var(--background)]">
                {f.icon}
              </div>
              <h3 className="mt-6 text-[17px] font-semibold tracking-tight text-[var(--foreground)] transition-colors duration-200">
                {f.title}
              </h3>
              <p className="mt-2 text-[15.5px] sm:text-base leading-relaxed text-[color-mix(in_oklch,var(--foreground)_60%,transparent)]">
                {f.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
