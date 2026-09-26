"use client";

import { useUiStore } from "@/store/useUIStore";
import Produit from "./produit/page";
import Image from "next/image";
import { CongoFlag, MadagascarFlag } from "@/components/ui/flag";
import CommentCaMarche from "./comment-ca-marche/page";
import APropos from "./a-propos/page";
import ContactForm from "@/components/contact-form";
import FeaturesSection from "@/components/features-section";
import ScrollReveal from "@/components/ui/scroll-reveal";

const quickActions = [
  { label: "Acheter un numéro", hint: "Choisissez un pays", icon: "plus" },
  { label: "Recharger", hint: "Ajoutez du crédit", icon: "bolt" },
  { label: "Mes messages", hint: "Consultez vos SMS", icon: "chat" },
  { label: "Paramètres", hint: "Gérez votre compte", icon: "gear" },
] as const;

const connectedCountries = [
  { name: 'France', code: '+33' },
  { name: 'Canada', code: '+1' },
  { name: 'Royaume-Uni', code: '+44' },
];

function Icon({ name }: { name: (typeof quickActions)[number]["icon"] }) {
  const common = {
    width: 16,
    height: 16,
    viewBox: "0 0 24 24",
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };
  switch (name) {
    case "plus":
      return (
        <svg {...common}>
          <path d="M12 5v14M5 12h14" />
        </svg>
      );
    case "bolt":
      return (
        <svg {...common}>
          <path d="M13 3 4 14h6l-1 7 9-11h-6l1-7Z" />
        </svg>
      );
    case "chat":
      return (
        <svg {...common}>
          <path d="M21 15a2 2 0 0 1-2 2H8l-5 4V6a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v9Z" />
        </svg>
      );
    case "gear":
      return (
        <svg {...common}>
          <circle cx="12" cy="12" r="3" />
          <path d="M19.4 13.5a7.4 7.4 0 0 0 0-3l1.8-1.4-2-3.4-2.1.6a7.6 7.6 0 0 0-2.6-1.5L14 2.5h-4l-.5 2.3a7.6 7.6 0 0 0-2.6 1.5l-2.1-.6-2 3.4L4.6 10.5a7.4 7.4 0 0 0 0 3l-1.8 1.4 2 3.4 2.1-.6c.75.66 1.63 1.17 2.6 1.5l.5 2.3h4l.5-2.3a7.6 7.6 0 0 0 2.6-1.5l2.1.6 2-3.4-1.8-1.4Z" />
        </svg>
      );
  }
}

function Hero() {
  const language = useUiStore((state) => state.language);
  const isFrench = language === "fr";
  const content = isFrench
    ? {
        title: "Le monde, à portée de numéro.",
        description: "Obtenez et gérez des numéros internationaux. Payez localement avec votre Mobile Money. Connectez-vous au monde, simplement.",
        getNumber: "Télécharger l'App",
        discover: "Découvrir AfriNumber",
        international: "International",
        greeting: "Bonjour, Sata",
        connected: "Connectée au monde.",
        yourNumber: "Votre numéro",
        active: "Actif",
        manage: "Gérer mon numéro",
        quickActions: "Actions rapides",
        connect: "Connectez-vous au monde",
        home: "Accueil",
        numbers: "Numéros",
        messages: "SMS",
        profile: "Profil",
      }
    : {
        title: "The world, one number away.",
        description: "Get and manage international numbers. Pay locally with Mobile Money. Connect to the world, simply.",
        getNumber: "Download the App",
        discover: "Discover AfriNumber",
        international: "International",
        greeting: "Hello, Sata",
        connected: "Connected to the world.",
        yourNumber: "Your number",
        active: "Active",
        manage: "Manage my number",
        quickActions: "Quick actions",
        connect: "Connect to the world",
        home: "Home",
        numbers: "Numbers",
        messages: "SMS",
        profile: "Profile",
      };
  const actions = isFrench
    ? ["Acheter un numéro", "Recharger", "Mes messages", "Paramètres"]
    : ["Buy a number", "Top up", "My messages", "Settings"];
  return (
    <section className="relative overflow-hidden pt-6 pb-16 sm:pb-24 lg:pb-28">
      {/* Halos de lumière décoratifs subtils */}
      <div 
        aria-hidden 
        className="pointer-events-none absolute -top-40 right-[-10%] h-[550px] w-[550px] rounded-full bg-[radial-gradient(circle,color-mix(in_oklch,var(--foreground)_6%,transparent)_0%,transparent_70%)] blur-[100px] animate-ambient-glow" 
      />
      <div 
        aria-hidden 
        className="pointer-events-none absolute top-1/2 left-[-15%] h-[450px] w-[450px] rounded-full bg-[radial-gradient(circle,color-mix(in_oklch,var(--foreground)_4%,transparent)_0%,transparent_70%)] blur-[90px] animate-ambient-glow" 
      />

      <div className="section-container">
        <div className="grid grid-cols-1 items-center gap-12 lg:grid-cols-[1fr_1.05fr] lg:gap-12 xl:gap-16">
          {/* Colonne texte */}
          <div className="relative z-10 max-w-xl motion-enter">
            <h1 className="text-[clamp(2.35rem,7.5vw,3.75rem)] font-semibold leading-[1.06] tracking-tight text-[var(--foreground)]">
              {content.title}
            </h1>

            <p className="mt-6 max-w-md text-[15.5px] leading-relaxed text-[color-mix(in_oklch,var(--foreground)_60%,transparent)] sm:text-base">
              {content.description}
            </p>

            <div className="mt-8 flex flex-col items-stretch gap-3 min-[420px]:flex-row min-[420px]:flex-wrap min-[420px]:items-center">
              <a
                href="#telechargement"
                className="group inline-flex min-h-12 items-center justify-center gap-2 rounded-full bg-[var(--foreground)] px-6 py-3.5 text-[13.5px] font-medium text-[var(--background)] transition-all duration-300 ease-out hover:scale-[1.03] hover:shadow-lg active:scale-[0.98]"
              >
                {content.getNumber}
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="transition-transform duration-300 ease-out group-hover:translate-x-0.5">
                  <path d="M5 12h14M13 6l6 6-6 6" />
                </svg>
              </a>
              <a
                href="#produit"
                className="inline-flex min-h-12 items-center justify-center rounded-full border border-[color-mix(in_oklch,var(--foreground)_16%,transparent)] px-6 py-3.5 text-[13.5px] font-medium transition-all duration-300 ease-out hover:bg-[color-mix(in_oklch,var(--foreground)_5%,transparent)] hover:scale-[1.02] active:scale-[0.98]"
              >
                {content.discover}
              </a>
            </div>

            <div className="mt-10 flex flex-wrap items-center gap-x-5 gap-y-2 text-[13px] text-[color-mix(in_oklch,var(--foreground)_55%,transparent)]">
              <span className="flex items-center gap-2 transition-transform duration-300 hover:scale-105">
                <MadagascarFlag className="h-5 w-7 rounded-sm shadow-xs" />
                Madagascar
              </span>
              <span className="opacity-40">•</span>
              <span className="flex items-center gap-2 transition-transform duration-300 hover:scale-105">
                <CongoFlag className="h-5 w-7 rounded-sm shadow-xs" />
                Congo
              </span>
              <span className="opacity-40">•</span>
              <span className="flex items-center gap-1.5 transition-colors duration-300 hover:text-[var(--foreground)]">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6">
                  <circle cx="12" cy="12" r="9" />
                  <path d="M3 12h18M12 3c2.4 2.5 3.7 5.6 3.7 9s-1.3 6.5-3.7 9c-2.4-2.5-3.7-5.6-3.7-9s1.3-6.5 3.7-9Z" />
                </svg>
                {content.international}
              </span>
            </div>
          </div>

          {/* Double mockup avec animation de flottement fluide */}
          <div className="relative flex w-full justify-center pt-6 motion-enter motion-delay-1 lg:justify-end lg:pt-0">
            <div className="relative min-h-[min(640px,145vw)] w-full max-w-[580px]">
              {/* Téléphone arrière , pays disponibles */}
              <div className="animate-float-hero-back absolute right-0 top-6 aspect-[9/19.5] w-[min(280px,calc(100vw-3rem))] rounded-[2.2rem] border border-[color-mix(in_oklch,var(--foreground)_14%,transparent)] bg-[var(--foreground)] p-2.5 shadow-[0_32px_64px_-16px_rgba(0,0,0,0.4)] transition-shadow duration-500 hover:shadow-[0_40px_80px_-16px_rgba(0,0,0,0.5)]">
                <div className="relative h-full w-full overflow-hidden rounded-[1.7rem] bg-[var(--background)]">
                  <Image
                    src="/images/banners.png"
                    alt="Aperçu de l'application AfriNumber"
                    fill
                    sizes="280px"
                    className="object-cover"
                  />
                </div>
              </div>

              {/* Téléphone avant , app */}
              <div className="animate-float-hero-front relative z-10 aspect-[9/19.5] w-[min(280px,calc(100vw-3rem))] rounded-[2.2rem] border border-[color-mix(in_oklch,var(--foreground)_14%,transparent)] bg-[var(--background)] p-2.5 shadow-[0_32px_64px_-16px_rgba(0,0,0,0.4)] transition-shadow duration-500 hover:shadow-[0_40px_80px_-16px_rgba(0,0,0,0.5)]">
                <div className="absolute left-1/2 top-2.5 z-20 h-4 w-16 -translate-x-1/2 rounded-full bg-[var(--foreground)]" />
                <div className="relative h-full overflow-hidden rounded-[1.7rem] border border-[color-mix(in_oklch,var(--foreground)_8%,transparent)] bg-[color-mix(in_oklch,var(--foreground)_2%,var(--background))] px-3.5 pb-4 pt-9">
                  <Image
                    src="/images/banners1.png"
                    alt="Interface de l'application AfriNumber"
                    fill
                    sizes="280px"
                    className="z-20 object-cover"
                  />
                  {/* Header app */}
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-[13px] font-semibold">{content.greeting}</p>
                      <p className="text-[10.5px] text-[color-mix(in_oklch,var(--foreground)_50%,transparent)]">
                        {content.connected}
                      </p>
                    </div>
                    <div className="flex h-7 w-7 items-center justify-center rounded-full bg-[color-mix(in_oklch,var(--foreground)_6%,transparent)] transition-transform duration-300 hover:scale-110">
                      <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6">
                        <path d="M18 8a6 6 0 1 0-12 0c0 7-3 9-3 9h18s-3-2-3-9Z" />
                        <path d="M13.7 21a2 2 0 0 1-3.4 0" />
                      </svg>
                    </div>
                  </div>

                  {/* Carte numéro */}
                  <div className="mt-4 rounded-2xl bg-[var(--foreground)] p-4 text-[var(--background)] shadow-md transition-transform duration-300 hover:scale-[1.02]">
                    <div className="flex items-center justify-between">
                      <span className="text-[10px] opacity-60">{content.yourNumber}</span>
                      <span className="flex items-center gap-1.5 rounded-full bg-[color-mix(in_oklch,var(--background)_18%,transparent)] px-2 py-0.5 text-[9px] font-medium">
                        <span className="h-1.5 w-1.5 rounded-full bg-emerald-400 animate-pulse" />
                        {content.active}
                      </span>
                    </div>
                    <p className="mt-1.5 text-[15px] font-semibold tracking-tight">+1 415 555 0123</p>
                    <p className="text-[10.5px] opacity-60">États-Unis</p>
                    <span className="group/btn mt-3 flex w-full items-center justify-center gap-1 rounded-full bg-[color-mix(in_oklch,var(--background)_14%,transparent)] py-2 text-[10.5px] font-medium transition-colors hover:bg-[color-mix(in_oklch,var(--background)_22%,transparent)]">
                      {content.manage}
                      <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="transition-transform duration-300 group-hover/btn:translate-x-0.5">
                        <path d="M5 12h14M13 6l6 6-6 6" />
                      </svg>
                    </span>
                  </div>

                  {/* Actions rapides */}
                  <p className="mb-2.5 mt-4 text-[10.5px] font-medium text-[color-mix(in_oklch,var(--foreground)_55%,transparent)]">
                    {content.quickActions}
                  </p>
                  <div className="grid grid-cols-2 gap-2">
                    {actions.map((action, index) => (
                      <div
                        key={action}
                        className="group/action rounded-xl border border-[color-mix(in_oklch,var(--foreground)_8%,transparent)] p-2.5 transition-all duration-300 hover:border-[color-mix(in_oklch,var(--foreground)_20%,transparent)] hover:bg-[color-mix(in_oklch,var(--foreground)_4%,var(--background))] hover:scale-[1.02]"
                      >
                        <div className="flex h-6 w-6 items-center justify-center rounded-full bg-[color-mix(in_oklch,var(--foreground)_6%,transparent)] transition-transform duration-300 group-hover/action:scale-110">
                          <Icon name={quickActions[index].icon} />
                        </div>
                        <p className="mt-1.5 text-[10px] font-medium leading-tight">{action}</p>
                      </div>
                    ))}
                  </div>

                  {/* Connecté au monde */}
                  <p className="mb-2 mt-4 text-[10.5px] font-medium text-[color-mix(in_oklch,var(--foreground)_55%,transparent)]">
                    {content.connect}
                  </p>
                  <div className="flex items-center gap-1.5">
                    {connectedCountries.map((c) => (
                      <span
                        key={c.code}
                        className="flex items-center gap-1 rounded-full border border-[color-mix(in_oklch,var(--foreground)_8%,transparent)] px-2 py-1 text-[9.5px] transition-all duration-300 hover:border-[color-mix(in_oklch,var(--foreground)_25%,transparent)] hover:bg-[color-mix(in_oklch,var(--foreground)_4%,var(--background))]"
                      >
                        {c.name} {c.code}
                      </span>
                    ))}
                    <span className="text-[9.5px] text-[color-mix(in_oklch,var(--foreground)_45%,transparent)]">
                      +44 more
                    </span>
                  </div>

                  {/* Tab bar */}
                  <div className="mt-5 flex items-center justify-between border-t border-[color-mix(in_oklch,var(--foreground)_8%,transparent)] pt-3 text-[8.5px] text-[color-mix(in_oklch,var(--foreground)_45%,transparent)]">
                    <span className="font-medium text-[var(--foreground)]">{content.home}</span>
                    <span>{content.numbers}</span>
                    <span>{content.messages}</span>
                    <span>{content.profile}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

export default function HomePage() {
  return (
    <div className="bg-gradient-page min-h-screen text-[var(--foreground)]">
      <div id="accueil">
        <Hero />
      </div>
      <ScrollReveal animation="fade-up" delay={40}>
        <div id="produit">
          <Produit />
        </div>
      </ScrollReveal>
      <ScrollReveal animation="fade-up" delay={40}>
        <div id="fonctionnalite">
          <FeaturesSection />
        </div>
      </ScrollReveal>
      <ScrollReveal animation="fade-up" delay={40}>
        <div id="commentcamarche">
          <CommentCaMarche />
        </div>
      </ScrollReveal>
      <ScrollReveal animation="fade-up" delay={40}>
        <div id="aboutus">
          <APropos />
        </div>
      </ScrollReveal>
      <ScrollReveal animation="fade-up" delay={40}>
        <ContactForm />
      </ScrollReveal>
    </div>
  );
}
