"use client";

// Section "À propos" , AfriNumber
import { useCallback, useState } from "react";
import { useUiStore } from "@/store/useUIStore";
import GlobeComponent, { type Pays } from "@/components/globe-components";

const FLAGS: Record<string, string> = {
  CG: "🇨🇬",
  MG: "🇲🇬",
  FR: "🇫🇷",
};

function IconUnlock() {
  return (
    <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5" strokeWidth={1.5} stroke="currentColor" >
      <rect x="5" y="11" width="14" height="9" rx="2.2" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M8.5 11V8a3.5 3.5 0 0 1 6.5-1.8" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M12 14.8v2.4" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function IconBulb() {
  return (
    <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5" strokeWidth={1.5} stroke="currentColor" >
      <path d="M9 18h6M10 21h4" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M12 3a6.5 6.5 0 0 0-3.8 11.8c.6.45.8 1 .8 1.7h6c0-.7.2-1.25.8-1.7A6.5 6.5 0 0 0 12 3Z" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function IconOverlap() {
  return (
    <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5" strokeWidth={1.5} stroke="currentColor" >
      <circle cx="9.5" cy="12" r="5.5" strokeLinecap="round" strokeLinejoin="round" />
      <circle cx="14.5" cy="12" r="5.5" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function IconShield() {
  return (
    <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5" strokeWidth={1.5} stroke="currentColor" >
      <path d="M12 3.5 19 6v5.5c0 4.3-2.9 7.6-7 9-4.1-1.4-7-4.7-7-9V6l7-2.5Z" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M9 12.2 11.2 14.4 15.5 9.8" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function IconSpark() {
  return (
    <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5" strokeWidth={1.5} stroke="currentColor" >
      <path d="M12 4v4.5M12 15.5V20M4 12h4.5M15.5 12H20" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

export default function APropos() {
  const language = useUiStore((state) => state.language);
  const isFrench = language === "fr";

  const [pays, setPays] = useState<Pays[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const [retryToken, setRetryToken] = useState(0);

  const copy = isFrench
    ? {
      eyebrow: "À propos",
      title: "Pourquoi AfriNumber existe",
      description: "Moins de 10% de la population au Congo et à Madagascar possède une carte bancaire internationale, pourtant des milliers de freelances et d'entrepreneurs y perdent chaque mois des opportunités faute d'un numéro international. AfriNumber transforme le Mobile Money en passeport numérique vers le monde.",
      missionTitle: "Notre mission",
      missionText: "Rendre l'accès aux services numériques internationaux plus accessible et équitable pour tous les utilisateurs africains.",
      visionTitle: "Notre vision",
      visionText: "Bâtir une Afrique connectée, compétitive, autonome et technologiquement inclusive.",
      valuesTitle: "Nos valeurs",
      values: [
        { label: "Accessibilité", description: "Sans carte bancaire, sans barrière.", icon: <IconUnlock /> },
        { label: "Innovation", description: "Une IA pensée pour l'Afrique.", icon: <IconBulb /> },
        { label: "Inclusion", description: "Freelances, PME, tous concernés.", icon: <IconOverlap /> },
        { label: "Sécurité", description: "KYC automatisé, antifraude intégré.", icon: <IconShield /> },
        { label: "Simplicité", description: "Trois étapes, aucune complexité.", icon: <IconSpark /> },
      ],
      networkEyebrow: "Notre réseau",
      networkLoading: "Chargement des pays connectés…",
      networkConnected: "pays déjà connectés à AfriNumber",
      retry: "Réessayer",
      errorMsg: "Impossible de charger la liste des pays pour le moment.",
      operatorPartner: "Partenaire opérateur",
      statusActive: "Actif",
    }
    : {
      eyebrow: "About Us",
      title: "Why AfriNumber Exists",
      description: "Less than 10% of the population in Congo and Madagascar has an international bank card, yet thousands of freelancers and businesses lose international opportunities every month without a dedicated foreign number. AfriNumber turns local Mobile Money into a global digital passport.",
      missionTitle: "Our Mission",
      missionText: "Make access to international digital communication services seamless, fair, and accessible to every African entrepreneur.",
      visionTitle: "Our Vision",
      visionText: "Foster an interconnected, competitive, independent, and technologically inclusive Africa.",
      valuesTitle: "Our Values",
      values: [
        { label: "Accessibility", description: "No credit card needed, no barriers.", icon: <IconUnlock /> },
        { label: "Innovation", description: "AI engineered for African needs.", icon: <IconBulb /> },
        { label: "Inclusion", description: "Freelancers, SMEs, startups, everyone.", icon: <IconOverlap /> },
        { label: "Security", description: "Automated KYC & built-in fraud prevention.", icon: <IconShield /> },
        { label: "Simplicity", description: "Three easy steps, zero hassle.", icon: <IconSpark /> },
      ],
      networkEyebrow: "Our Network",
      networkLoading: "Loading connected countries…",
      networkConnected: "countries already connected to AfriNumber",
      retry: "Retry",
      errorMsg: "Unable to load the list of countries at this time.",
      operatorPartner: "Telecom partner",
      statusActive: "Active",
    };

  const onPaysChange = useCallback((list: Pays[]) => {
    setPays(list);
    setSelectedId((current) => list.some((country) => country.id === current)
      ? current
      : list.find((country) => country.actif)?.id ?? list[0]?.id ?? null);
  }, []);
  const onLoadingChange = useCallback(setLoading, []);
  const onErrorChange = useCallback(setError, []);
  return (
    <section id="aboutus" className="relative overflow-hidden section-padding" >
      <div className="section-container" >
        {/* En-tête uniforme */}
        < div className="section-header" >
          <span className="section-eyebrow" >
            <span className="h-1.5 w-1.5 rounded-full bg-current" />
            {copy.eyebrow}
          </span>
          < h2 className="section-title" >
            {copy.title}
          </h2>
          < p className="section-description" >
            {copy.description}
          </p>
        </div>

        {/* Mission & Vision */}
        <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 sm:gap-6" >
          <div className="rounded-[1.75rem] border border-[color-mix(in_oklch,var(--foreground)_10%,transparent)] bg-[color-mix(in_oklch,var(--foreground)_3.5%,var(--background))] p-8 sm:p-10 transition-all duration-300 ease-out hover:-translate-y-1.5 hover:border-[color-mix(in_oklch,var(--foreground)_25%,transparent)] hover:shadow-[0_24px_48px_-20px_rgba(0,0,0,0.18)]" >
            <span className="text-[13px] uppercase tracking-[0.14em] font-medium text-[color-mix(in_oklch,var(--foreground)_45%,transparent)]" >
              {copy.missionTitle}
            </span>
            < p className="mt-3 text-[17px] sm:text-[19px] font-semibold tracking-tight leading-snug text-[var(--foreground)]" >
              {copy.missionText}
            </p>
          </div>

          < div className="rounded-[1.75rem] border border-[color-mix(in_oklch,var(--foreground)_10%,transparent)] bg-[color-mix(in_oklch,var(--foreground)_3.5%,var(--background))] p-8 sm:p-10 transition-all duration-300 ease-out hover:-translate-y-1.5 hover:border-[color-mix(in_oklch,var(--foreground)_25%,transparent)] hover:shadow-[0_24px_48px_-20px_rgba(0,0,0,0.18)]" >
            <span className="text-[13px] uppercase tracking-[0.14em] font-medium text-[color-mix(in_oklch,var(--foreground)_45%,transparent)]" >
              {copy.visionTitle}
            </span>
            < p className="mt-3 text-[17px] sm:text-[19px] font-semibold tracking-tight leading-snug text-[var(--foreground)]" >
              {copy.visionText}
            </p>
          </div>
        </div>

        {/* Valeurs */}
        <div className="mt-16 sm:mt-20" >
          <span className="block text-center text-[13px] uppercase tracking-[0.14em] font-medium text-[color-mix(in_oklch,var(--foreground)_55%,transparent)]" >
            {copy.valuesTitle}
          </span>
          < div className="mt-8 grid grid-cols-2 gap-4 sm:grid-cols-5 sm:gap-5" >
            {
              copy.values.map((valeur) => (
                <div
                  key={valeur.label}
                  className="group flex flex-col items-center gap-3 rounded-[1.75rem] border border-[color-mix(in_oklch,var(--foreground)_10%,transparent)] bg-[color-mix(in_oklch,var(--foreground)_3.5%,var(--background))] px-4 py-7 text-center transition-all duration-300 ease-out hover:-translate-y-1.5 hover:border-[color-mix(in_oklch,var(--foreground)_25%,transparent)] hover:bg-[color-mix(in_oklch,var(--foreground)_6%,var(--background))] hover:shadow-[0_20px_40px_-15px_rgba(0,0,0,0.18)]"
                >
                  <span className="flex h-11 w-11 items-center justify-center rounded-full border border-[color-mix(in_oklch,var(--foreground)_14%,transparent)] bg-[var(--background)] text-[var(--foreground)] transition-all duration-300 group-hover:scale-110 group-hover:bg-[var(--foreground)] group-hover:text-[var(--background)]" >
                    {valeur.icon}
                  </span>
                  < span className="text-[13.5px] font-medium tracking-tight text-[var(--foreground)]" >
                    {valeur.label}
                  </span>
                  < span className="text-[12.5px] leading-snug text-[color-mix(in_oklch,var(--foreground)_55%,transparent)]" >
                    {valeur.description}
                  </span>
                </div>
              ))
            }
          </div>
        </div>

        {/* Carte OpenStreetMap & réseau */}
        <div className="mt-20 sm:mt-28 rounded-[1.75rem] border border-[color-mix(in_oklch,var(--foreground)_10%,transparent)] bg-[color-mix(in_oklch,var(--foreground)_3.5%,var(--background))] px-6 sm:px-12 py-12 sm:py-16" >
          <div className="mb-10 sm:mb-14 flex flex-col items-center gap-2 text-center" >
            <span className="text-[13px] uppercase tracking-[0.14em] font-medium text-[color-mix(in_oklch,var(--foreground)_55%,transparent)]" >
              {copy.networkEyebrow}
            </span>
            < h3 className="text-[19px] sm:text-[21px] font-semibold tracking-tight text-[var(--foreground)]" >
              {
                loading
                  ? copy.networkLoading
                  : error
                    ? copy.networkEyebrow
                    : `${pays.length} ${copy.networkConnected}`
              }
            </h3>
          </div>

          <div className="grid grid-cols-1 items-center gap-6 lg:grid-cols-[1.65fr_0.85fr] lg:gap-8" >
                <div className="flex min-h-[500px] items-center justify-center overflow-hidden">
                  <GlobeComponent
                    onPaysChange={onPaysChange}
                    onLoadingChange={onLoadingChange}
                    onErrorChange={onErrorChange}
                    errorMessage={copy.errorMsg}
                    retryToken={retryToken}
                    isFrench={isFrench}
                  />
                </div>
                {/* Liste des pays */}
                <div className="flex flex-col gap-3" >
                  {error ? (
                    <div className="flex flex-col items-center gap-4 rounded-2xl border border-[color-mix(in_oklch,var(--foreground)_10%,transparent)] p-6 text-center" role="alert">
                      <p className="text-[15px] text-[color-mix(in_oklch,var(--foreground)_60%,transparent)]">{error}</p>
                      <button
                        type="button"
                        onClick={() => setRetryToken((token) => token + 1)}
                        className="rounded-full border border-[color-mix(in_oklch,var(--foreground)_16%,transparent)] px-5 py-2.5 text-[13.5px] font-medium transition-colors hover:bg-[color-mix(in_oklch,var(--foreground)_6%,var(--background))]"
                      >
                        {copy.retry}
                      </button>
                    </div>
                  ) : (
                    pays.map((p) => {
                      const isSelected = p.id === selectedId;
                      return (
                        <button
                          key={p.id}
                          type="button"
                          onClick={() => setSelectedId(p.id)
                          }
                          className={`group flex items-center justify-between rounded-2xl border p-4 text-left transition-all duration-300 ${isSelected
                            ? "border-[var(--foreground)] bg-[color-mix(in_oklch,var(--foreground)_8%,var(--background))] shadow-sm"
                            : "border-[color-mix(in_oklch,var(--foreground)_10%,transparent)] bg-[var(--background)] hover:border-[color-mix(in_oklch,var(--foreground)_25%,transparent)] hover:bg-[color-mix(in_oklch,var(--foreground)_4%,var(--background))]"
                            }`}
                        >
                          <div className="flex items-center gap-3" >
                            <span className="text-2xl" > {FLAGS[p.code] ?? "🌐"} </span>
                            < div >
                              <p className="text-[15px] font-semibold tracking-tight text-[var(--foreground)]" >
                                {p.label}
                              </p>
                              < p className="text-[12px] text-[color-mix(in_oklch,var(--foreground)_55%,transparent)]" >
                                {p.indicatif}
                              </p>
                            </div>
                          </div>
                          {
                            p.actif && (
                              <span className="flex items-center gap-1.5 rounded-full bg-emerald-500/10 px-2.5 py-1 text-[11px] font-medium text-emerald-600 dark:text-emerald-400" >
                                <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
                                {copy.statusActive}
                              </span>
                            )
                          }
                        </button>
                      );
                    }))}
                </div>
              </div>
          </div>
      </div>
    </section>
  );
}
