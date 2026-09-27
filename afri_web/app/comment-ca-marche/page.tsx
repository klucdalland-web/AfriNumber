"use client";

// Section "Comment ça marche" , AfriNumber
import { useUiStore } from "@/store/useUIStore";

function IconPin() {
  return (
    <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5" strokeWidth={1.5} stroke="currentColor">
      <path d="M12 21s7-6.2 7-11.5A7 7 0 0 0 5 9.5C5 14.8 12 21 12 21Z" strokeLinecap="round" strokeLinejoin="round" />
      <circle cx="12" cy="9.5" r="2.4" strokeLinecap="round" strokeLinejoin="round" />
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

function IconLink() {
  return (
    <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5" strokeWidth={1.5} stroke="currentColor">
      <path d="M9.5 14.5 14.5 9.5" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M11 7.5 12.3 6.2a3.2 3.2 0 0 1 4.5 4.5L15.5 12" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M13 16.5 11.7 17.8a3.2 3.2 0 0 1-4.5-4.5L8.5 12" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function IconGlobe() {
  return (
    <svg viewBox="0 0 24 24" fill="none" className="w-[18px] h-[18px]" strokeWidth={1.5} stroke="currentColor">
      <circle cx="12" cy="12" r="8" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M12 4c2.2 2.3 3.3 5 3.3 8s-1.1 5.7-3.3 8c-2.2-2.3-3.3-5-3.3-8S9.8 6.3 12 4Z" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M4.5 10h15M4.5 14h15" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function IconHash() {
  return (
    <svg viewBox="0 0 24 24" fill="none" className="w-[18px] h-[18px]" strokeWidth={1.5} stroke="currentColor">
      <path d="M9.5 4.5 7.5 19.5M16.5 4.5l-2 15M5 9h15M4 15h15" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function IconBox() {
  return (
    <svg viewBox="0 0 24 24" fill="none" className="w-[18px] h-[18px]" strokeWidth={1.5} stroke="currentColor">
      <path d="M4 8.2 12 4l8 4.2v7.6L12 20l-8-4.2V8.2Z" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M4 8.2 12 12l8-3.8M12 12v8" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function IconCheck() {
  return (
    <svg viewBox="0 0 24 24" fill="none" className="w-[18px] h-[18px]" strokeWidth={1.5} stroke="currentColor">
      <circle cx="12" cy="12" r="8.5" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M8.5 12.3 11 14.8l4.5-5.6" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function IconSignal() {
  return (
    <svg viewBox="0 0 24 24" fill="none" className="w-[18px] h-[18px]" strokeWidth={1.5} stroke="currentColor">
      <path d="M5 17v-2.5M9.5 17V11M14 17V7.5M18.5 17V4" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

export default function CommentCaMarche() {
  const language = useUiStore((state) => state.language);
  const isFrench = language === "fr";

  const copy = isFrench
    ? {
        eyebrow: "Comment ça marche",
        title: "Trois étapes. Une connexion mondiale.",
        description: "Aucune carte bancaire, aucune complexité , juste votre pays, votre Mobile Money, et un numéro actif en quelques minutes.",
        stepLabel: "Étape",
        steps: [
          {
            number: "01",
            title: "Choisissez",
            description: "Sélectionnez votre pays et le service souhaité.",
            icon: <IconPin />,
          },
          {
            number: "02",
            title: "Payez",
            description: "Payez avec votre moyen de paiement local (Mobile Money).",
            icon: <IconWallet />,
          },
          {
            number: "03",
            title: "Connectez-vous",
            description: "Gérez votre numéro et vos communications internationales.",
            icon: <IconLink />,
          },
        ],
        journeyTitle: "Le parcours complet",
        journeySubtitle: "Du choix du pays au numéro actif",
        journey: [
          { label: "Pays", icon: <IconGlobe /> },
          { label: "Numéro", icon: <IconHash /> },
          { label: "Forfait", icon: <IconBox /> },
          { label: "Mobile Money", icon: <IconWallet /> },
          { label: "Confirmation", icon: <IconCheck /> },
          { label: "Numéro actif", icon: <IconSignal />, active: true },
        ],
      }
    : {
        eyebrow: "How It Works",
        title: "Three steps. One global connection.",
        description: "No credit card, no complexity — just choose your country, pay with Mobile Money, and get an active number in minutes.",
        stepLabel: "Step",
        steps: [
          {
            number: "01",
            title: "Select",
            description: "Choose your destination country and desired plan.",
            icon: <IconPin />,
          },
          {
            number: "02",
            title: "Pay",
            description: "Pay directly with your local Mobile Money account.",
            icon: <IconWallet />,
          },
          {
            number: "03",
            title: "Connect",
            description: "Manage your number and international communications seamlessly.",
            icon: <IconLink />,
          },
        ],
        journeyTitle: "The Complete Journey",
        journeySubtitle: "From country selection to your live active number",
        journey: [
          { label: "Country", icon: <IconGlobe /> },
          { label: "Number", icon: <IconHash /> },
          { label: "Plan", icon: <IconBox /> },
          { label: "Mobile Money", icon: <IconWallet /> },
          { label: "Confirmation", icon: <IconCheck /> },
          { label: "Active number", icon: <IconSignal />, active: true },
        ],
      };

  return (
    <section id="commentcamarche" className="relative overflow-hidden section-padding">
      {/* Texture de fond */}
      <div
        aria-hidden
        className="pointer-events-none absolute inset-0"
        style={{
          backgroundImage:
            "radial-gradient(color-mix(in oklch, var(--foreground) 16%, transparent) 1px, transparent 1px)",
          backgroundSize: "24px 24px",
          maskImage:
            "radial-gradient(ellipse 65% 55% at 50% 25%, black 30%, transparent 100%)",
          WebkitMaskImage:
            "radial-gradient(ellipse 65% 55% at 50% 25%, black 30%, transparent 100%)",
        }}
      />

      <div className="relative section-container">
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

        {/* 3 étapes, reliées par une ligne de signal animée */}
        <div className="relative">
          <svg
            aria-hidden
            viewBox="0 0 600 120"
            preserveAspectRatio="none"
            className="pointer-events-none absolute left-0 right-0 top-[34px] hidden h-[64px] w-full sm:block opacity-60"
          >
            <path
              d="M100,60 C170,18 230,102 300,60 C370,18 430,102 500,60"
              fill="none"
              stroke="color-mix(in oklch, var(--foreground) 25%, transparent)"
              strokeWidth="2"
              strokeDasharray="4 6"
              strokeLinecap="round"
              className="animate-signal-flow"
            />
          </svg>

          <div className="grid grid-cols-1 gap-5 sm:grid-cols-3 sm:gap-6">
            {copy.steps.map((step) => (
              <div
                key={step.number}
                className="group relative rounded-[1.75rem] border border-[color-mix(in_oklch,var(--foreground)_10%,transparent)] bg-[color-mix(in_oklch,var(--foreground)_3.5%,var(--background))] p-7 sm:p-8 transition-all duration-300 ease-out hover:-translate-y-1.5 hover:border-[color-mix(in_oklch,var(--foreground)_25%,transparent)] hover:bg-[color-mix(in_oklch,var(--foreground)_6%,var(--background))] hover:shadow-[0_24px_48px_-20px_rgba(0,0,0,0.22)]"
              >
                <div className="relative z-10 flex h-12 w-12 items-center justify-center rounded-full border border-[color-mix(in_oklch,var(--foreground)_14%,transparent)] bg-[var(--background)] text-[var(--foreground)] transition-all duration-300 ease-out group-hover:scale-110 group-hover:bg-[var(--foreground)] group-hover:text-[var(--background)]">
                  {step.icon}
                </div>

                <span className="mt-6 block text-[13px] uppercase tracking-[0.14em] font-medium text-[color-mix(in_oklch,var(--foreground)_45%,transparent)]">
                  {copy.stepLabel} {step.number}
                </span>
                <h3 className="mt-1.5 text-[17px] font-semibold tracking-tight text-[var(--foreground)] transition-colors duration-200">
                  {step.title}
                </h3>
                <p className="mt-2 text-[15.5px] sm:text-base leading-relaxed text-[color-mix(in_oklch,var(--foreground)_60%,transparent)]">
                  {step.description}
                </p>
              </div>
            ))}
          </div>
        </div>

        {/* Parcours détaillé */}
        <div className="mt-20 sm:mt-28 rounded-[1.75rem] border border-[color-mix(in_oklch,var(--foreground)_10%,transparent)] bg-[color-mix(in_oklch,var(--foreground)_3.5%,var(--background))] px-6 sm:px-12 py-12 sm:py-16 transition-shadow duration-300 hover:shadow-lg">
          <div className="mb-14 sm:mb-20 text-center">
            <span className="text-[13px] uppercase tracking-[0.14em] font-medium text-[color-mix(in_oklch,var(--foreground)_55%,transparent)]">
              {copy.journeyTitle}
            </span>
            <h3 className="mt-3 text-[19px] sm:text-[21px] font-semibold tracking-tight text-[var(--foreground)]">
              {copy.journeySubtitle}
            </h3>
          </div>

          {/* Desktop : timeline en zigzag, reliée par une ligne de signal animée */}
          <div className="relative hidden sm:block">
            <svg
              aria-hidden
              viewBox="0 0 1200 160"
              preserveAspectRatio="none"
              className="pointer-events-none absolute inset-x-0 top-0 h-[90px] w-full opacity-60"
            >
              <path
                d="M100,110 C160,40 220,40 280,80 C340,120 380,120 460,60 C520,15 560,15 620,70 C680,130 720,130 780,70 C840,10 880,10 940,60 C980,95 1020,95 1100,50"
                fill="none"
                stroke="color-mix(in oklch, var(--foreground) 20%, transparent)"
                strokeWidth="2"
                strokeDasharray="4 6"
                strokeLinecap="round"
                className="animate-signal-flow"
              />
            </svg>

            <ol className="relative flex items-start justify-between">
              {copy.journey.map((item, i) => (
                <li
                  key={item.label}
                  className={`group flex flex-col items-center gap-3 transition-transform duration-300 hover:scale-105 ${i % 2 === 0 ? "mt-0" : "mt-[52px]"}`}
                >
                  <span
                    className={`relative flex h-11 w-11 items-center justify-center rounded-full border transition-all duration-300 ${
                      item.active
                        ? "border-emerald-400/50 bg-emerald-400/15 text-emerald-500 shadow-md shadow-emerald-400/20"
                        : "border-[color-mix(in_oklch,var(--foreground)_14%,transparent)] bg-[var(--background)] text-[var(--foreground)] group-hover:border-[color-mix(in_oklch,var(--foreground)_30%,transparent)] group-hover:scale-110"
                    }`}
                  >
                    {item.active && (
                      <span className="absolute inset-0 -z-10 animate-ping rounded-full bg-emerald-400/40" />
                    )}
                    {item.icon}
                  </span>
                  <span
                    className={`whitespace-nowrap text-[13.5px] font-medium tracking-tight transition-colors duration-200 ${
                      item.active ? "text-emerald-500 font-semibold" : "text-[var(--foreground)] group-hover:text-[var(--foreground)]"
                    }`}
                  >
                    {item.label}
                  </span>
                </li>
              ))}
            </ol>
          </div>

          {/* Mobile : timeline verticale */}
          <ol className="flex flex-col sm:hidden">
            {copy.journey.map((item, i) => (
              <li key={item.label} className="group flex gap-4 transition-transform duration-200 hover:translate-x-1">
                <div className="flex flex-col items-center">
                  <span
                    className={`relative flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-full border transition-all duration-300 ${
                      item.active
                        ? "border-emerald-400/50 bg-emerald-400/15 text-emerald-500 shadow-md shadow-emerald-400/20"
                        : "border-[color-mix(in_oklch,var(--foreground)_14%,transparent)] bg-[var(--background)] text-[var(--foreground)]"
                    }`}
                  >
                    {item.active && (
                      <span className="absolute inset-0 -z-10 animate-ping rounded-full bg-emerald-400/40" />
                    )}
                    {item.icon}
                  </span>
                  {i < copy.journey.length - 1 && (
                    <span className="my-1 h-8 w-px bg-[color-mix(in_oklch,var(--foreground)_12%,transparent)]" />
                  )}
                </div>
                <div className="pb-8 pt-2">
                  <span
                    className={`text-[15.5px] font-medium tracking-tight ${
                      item.active ? "text-emerald-500 font-semibold" : "text-[var(--foreground)]"
                    }`}
                  >
                    {item.label}
                  </span>
                </div>
              </li>
            ))}
          </ol>
        </div>
      </div>
    </section>
  );
}