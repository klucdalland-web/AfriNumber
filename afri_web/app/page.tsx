"use client";
import { ArrowRight, Download, Globe } from "lucide-react";
import { useUiStore } from "@/store/useUIStore";
import { CongoFlag, MadagascarFlag } from "@/components/ui/flag";
import Image from "next/image";
// Si Inter est déjà chargé globalement dans app/layout.tsx, tu peux supprimer
// ce bloc et remplacer `inter.className` par rien (ou par ta classe globale).
function Hero() {
    const language = useUiStore((state) => state.language);
    const content = language === "fr"
        ? {
            eyebrow: "La communication professionnelle des entrepreneurs africains",
            title: "Le monde, à portée de numéro.",
            description: "AfriNumber donne aux freelances et entrepreneurs africains un numéro de téléphone international, activable en quelques minutes et payable directement en Mobile Money, sans carte bancaire et sans frontière.",
            cta: "Télécharger l'application",
            discover: "Découvrir AfriNumber",
            compatible: "Compatible avec",
            fallback: "Dépose ta capture d'écran dans",
        }
        : {
            eyebrow: "Professional communication for African entrepreneurs",
            title: "The world, one number away.",
            description: "AfriNumber gives African freelancers and entrepreneurs an international phone number, activated in minutes and paid directly with Mobile Money, with no bank card and no borders.",
            cta: "Download the app",
            discover: "Discover AfriNumber",
            compatible: "Works with",
            fallback: "Add your app screenshot to",
        };

    return (
        <section
            className="relative overflow-hidden bg-background text-foreground"
            id="accueil"
        >
            {/* Anneaux de signal en fond — évoquent un appel/une connexion, très discrets */}
            <div
                aria-hidden
                className="pointer-events-none absolute -right-40 top-1/2 hidden h-[720px] w-[720px] -translate-y-1/2 rounded-full border border-foreground/[0.06] md:block"
            />
            <div
                aria-hidden
                className="pointer-events-none absolute -right-40 top-1/2 hidden h-[560px] w-[560px] -translate-y-1/2 rounded-full border border-foreground/[0.08] md:block"
            />
            <div
                aria-hidden
                className="pointer-events-none absolute -right-40 top-1/2 hidden h-[400px] w-[400px] -translate-y-1/2 rounded-full border border-foreground/[0.10] md:block"
            />

            <div className="mx-auto grid max-w-6xl grid-cols-1 items-center gap-16 px-6 py-24 md:grid-cols-2 md:gap-12 md:py-32">
                {/* Colonne texte */}
                <div className="relative z-10 max-w-xl">
                    <p className="mb-5 text-xs font-semibold uppercase tracking-[0.2em] text-foreground/60">
                        {content.eyebrow}
                    </p>
                    <h1 className="text-4xl font-semibold leading-[1.1] tracking-tight sm:text-5xl lg:text-6xl">
                        {content.title}
                    </h1>

                    <p className="mt-6 text-lg leading-relaxed text-foreground/70">
                        {content.description}
                    </p>

                    <div className="mt-10 flex flex-wrap items-center gap-4">
                        <a
                            href="#telecharger"
                            className="inline-flex items-center justify-center rounded-full bg-foreground px-7 py-3.5 text-sm font-medium text-background transition-transform duration-200 hover:scale-[1.03] active:scale-[0.98]"
                        >
                            {content.cta} <Download className=" px-0.5 h-5 w-5" />
                        </a>
                        <a
                            href="#telecharger"
                            className="inline-flex items-center justify-center rounded-full border-2 border-foreground bg-background px-7 py-3.5 text-sm font-bold text-foreground transition-transform duration-200 hover:bg-foreground hover:text-background hover:scale-[1.03] active:scale-[0.98]"
                        >
                            {content.discover} <ArrowRight className=" px-0.5 h-5 w-5" />
                        </a>
                    </div>

                    <div className="mt-10 flex flex-wrap items-center gap-x-6 gap-y-2 text-xs text-foreground/45">
                        <span className="text-foreground/70">
                            <div className="flex items-center gap-3">
                                <div className="h-6 w-6 rounded-full overflow-hidden flex items-center justify-center border border-stone-100">
                                    {/* On force le SVG à remplir le cercle */}
                                    <MadagascarFlag className="h-6 w-9 max-w-none transform scale-110" />
                                </div>
                                <span className="text-sm font-medium font-bold text-foreground">Madagascar</span>
                            </div>
                        </span>
                        <span className="text-foreground/70">
                            <div className="flex items-center gap-3">
                                <div className="h-6 w-6 rounded-full overflow-hidden flex items-center justify-center border border-stone-100">
                                    <CongoFlag className="h-6 w-9 max-w-none transform scale-110" />
                                </div>
                                <span className="text-sm font-medium font-bold text-foreground">Congo</span>
                            </div>
                        </span>
                        <span className="text-foreground/70">
                        <div className="flex items-center gap-3 font-bold text-foreground">
                            <Globe className="h-6 w-6 animate-pulse" />
                            International
                        </div>                
                        </span>
                    </div>
                </div>

                {/* Colonne mockup */}
                <div className="relative z-10 flex justify-center md:justify-end">
                    <div className="relative w-[260px] rotate-[4deg] sm:w-[300px]">
                        {/* Châssis du téléphone */}
                        <div className="relative aspect-[9/19.5] w-full rounded-[2.5rem] border border-foreground/70 bg-foreground/5 p-3 shadow-[0_40px_80px_-20px_rgba(0,0,0,0.18)]">
                            {/* Écran — remplace le contenu ci-dessous par ta vraie capture d'écran */}
                            <div className="relative h-full w-full overflow-hidden rounded-[1.8rem] bg-foreground/10">
                                {/* Repli affiché tant qu'aucune image n'est fournie */}
                                <div className="absolute inset-0 flex items-center justify-center border border-dashed border-foreground/15 p-6 text-center text-xs leading-relaxed text-foreground/35">
                                    <Image
                                        src="/images/banners.png"
                                        alt="Interface AfriNumber"
                                        fill
                                        sizes="300px"
                                        className="object-cover"
                                    />
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
        <div id="accueil">
            <Hero />
        </div>
    );
}
