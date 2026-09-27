"use client";

import dynamic from "next/dynamic";
import { useCallback, useEffect, useRef, useState } from "react";
import { useUiStore } from "@/store/useUIStore";

export type Pays = {
    id: number;
    label: string;
    code: string;
    indicatif: string;
    actif: boolean;
    organisation_id: number;
    organisation?: { id: number; label: string; description: string };
};

type GlobeComponentProps = {
    onPaysChange: (pays: Pays[]) => void;
    onLoadingChange: (loading: boolean) => void;
    onErrorChange: (error: string | null) => void;
    errorMessage: string;
    retryToken: number;
    isFrench: boolean;
};

const COUNTRY_COORDS: Record<string, [number, number]> = {
  // 🇲🇬 Afrique
  MG: [-18.88, 47.50], // Madagascar
  CG: [-4.26, 15.28], // Congo-Brazzaville
  CD: [-4.04, 21.76], // RD Congo
  ZA: [-30.56, 22.94], // Afrique du Sud
  KE: [0.02, 37.91], // Kenya
  TZ: [-6.37, 34.89], // Tanzanie
  UG: [1.37, 32.29], // Ouganda
  RW: [-1.94, 29.87], // Rwanda
  BI: [-3.37, 29.92], // Burundi
  ET: [9.15, 40.49], // Éthiopie
  SO: [5.15, 46.20], // Somalie
  DJ: [11.83, 42.59], // Djibouti
  EG: [26.82, 30.80], // Égypte
  SD: [12.86, 30.22], // Soudan
  SS: [6.88, 31.31], // Soudan du Sud
  NG: [9.08, 8.68], // Nigeria
  CI: [7.54, -5.55], // Côte d'Ivoire
  SN: [14.50, -14.45], // Sénégal
  ML: [17.57, -3.99], // Mali
  BF: [12.24, -1.56], // Burkina Faso
  NE: [17.61, 8.08], // Niger
  TD: [15.45, 18.73], // Tchad
  CM: [7.37, 12.35], // Cameroun
  GA: [-0.80, 11.61], // Gabon
  GQ: [1.65, 10.27], // Guinée équatoriale
  AO: [-11.20, 17.87], // Angola
  ZM: [-13.13, 27.85], // Zambie
  ZW: [-19.02, 29.15], // Zimbabwe
  MZ: [-18.67, 35.53], // Mozambique
  BW: [-22.33, 24.68], // Botswana
  NA: [-22.96, 18.49], // Namibie
  SZ: [-26.52, 31.47], // Eswatini
  LS: [-29.61, 28.23], // Lesotho
  MW: [-13.25, 34.30], // Malawi
  MR: [20.25, -10.94], // Mauritanie
  GN: [9.95, -11.83], // Guinée
  SL: [8.46, -11.78], // Sierra Leone
  LR: [6.43, -9.43], // Liberia
  TG: [8.62, 0.82], // Togo
  BJ: [9.31, 2.32], // Bénin
  GH: [7.95, -1.02], // Ghana
  CV: [16.00, -24.01], // Cap-Vert

  // Europe
  FR: [46.23, 2.21], // France
  DE: [51.17, 10.45], // Allemagne
  GB: [55.38, -3.44], // Royaume-Uni
  ES: [40.46, -3.75], // Espagne
  IT: [41.87, 12.57], // Italie
  PT: [39.40, -8.22], // Portugal
  NL: [52.13, 5.29], // Pays-Bas
  BE: [50.50, 4.47], // Belgique
  CH: [46.82, 8.23], // Suisse
  AT: [47.52, 14.55], // Autriche
  SE: [60.13, 18.64], // Suède
  NO: [60.47, 8.47], // Norvège
  FI: [64.00, 26.00], // Finlande
  PL: [51.92, 19.15], // Pologne
  GR: [39.07, 21.82], // Grèce
  IE: [53.41, -8.24], // Irlande
  UA: [48.38, 31.17], // Ukraine
  RO: [45.94, 24.97], // Roumanie
  CZ: [49.82, 15.47], // République tchèque
  HU: [47.16, 19.50], // Hongrie
  DK: [56.26, 9.50], // Danemark
  IS: [64.96, -19.02], // Islande

  // Amérique du Nord
  US: [37.09, -95.71], // États-Unis
  CA: [56.13, -106.35], // Canada
  MX: [23.63, -102.55], // Mexique
  CU: [21.52, -77.78], // Cuba
  CR: [9.75, -83.75], // Costa Rica
  PA: [8.54, -80.78], // Panama

  // Amérique du Sud
  BR: [-14.24, -51.93], // Brésil
  AR: [-38.42, -63.62], // Argentine
  CL: [-35.68, -71.54], // Chili
  PE: [-9.19, -75.02], // Pérou
  CO: [4.57, -74.30], // Colombie
  VE: [6.42, -66.59], // Venezuela
  BO: [-16.29, -63.59], // Bolivie
  EC: [-1.83, -78.18], // Équateur
  UY: [-32.52, -55.77], // Uruguay
  PY: [-23.44, -58.44], // Paraguay

  // Asie
  JP: [36.20, 138.25], // Japon
  CN: [35.86, 104.20], // Chine
  IN: [20.59, 78.96], // Inde
  KR: [35.91, 127.77], // Corée du Sud
  ID: [-0.79, 113.92], // Indonésie
  MY: [4.21, 101.98], // Malaisie
  SG: [1.35, 103.82], // Singapour
  TH: [15.87, 100.99], // Thaïlande
  VN: [14.06, 108.28], // Vietnam
  PH: [12.88, 121.77], // Philippines
  PK: [30.38, 69.35], // Pakistan
  BD: [23.68, 90.36], // Bangladesh
  NP: [28.39, 84.12], // Népal
  LK: [7.87, 80.77], // Sri Lanka
  SA: [23.89, 45.08], // Arabie saoudite
  AE: [23.42, 53.85], // Émirats arabes unis
  TR: [38.96, 35.24], // Turquie
  IL: [31.05, 34.85], // Israël

  // Océanie
  AU: [-25.27, 133.78], // Australie
  NZ: [-40.90, 174.89], // Nouvelle-Zélande
  FJ: [-17.71, 178.07], // Fidji
  PG: [-6.31, 143.96], // Papouasie-Nouvelle-Guinée
};

const Globe = dynamic(
    () => import("react-globe.gl"),
    {
        ssr: false,
    }
);

export default function GlobeComponent({ onPaysChange, onLoadingChange, onErrorChange, errorMessage, retryToken, isFrench }: GlobeComponentProps) {
    const theme = useUiStore((state) => state.theme);
    const [pays, setPays] = useState<Pays[]>([]);
    const [loading, setLoading] = useState(true);
    const [globeSize, setGlobeSize] = useState(560);
    const globeContainerRef = useRef<HTMLDivElement>(null);
    const errorMessageRef = useRef(errorMessage);
    errorMessageRef.current = errorMessage;

    useEffect(() => {
        const container = globeContainerRef.current;
        if (!container) return;
        const observer = new ResizeObserver(([entry]) => {
            if (entry) setGlobeSize(Math.min(640, Math.floor(entry.contentRect.width)));
        });
        observer.observe(container);
        return () => observer.disconnect();
    }, []);

    const fetchPays = useCallback(async (signal?: AbortSignal) => {
        setLoading(true);
        onLoadingChange(true);
        onErrorChange(null);
        try {
            const response = await fetch("/api/pays", {
                method: "GET",
                headers: { Accept: "application/json" },
                signal,
            });
            if (!response.ok) throw new Error(`HTTP ${response.status}`);
            const data = await response.json();
            const list: Pays[] = Array.isArray(data?.data?.pays) ? data.data.pays : [];
            setPays(list);
            onPaysChange(list);
        } catch {
            if (signal?.aborted) return;
            setPays([]);
            onPaysChange([]);
            onErrorChange(errorMessageRef.current);
        } finally {
            if (!signal?.aborted) {
                setLoading(false);
                onLoadingChange(false);
            }
        }
    }, [onErrorChange, onLoadingChange, onPaysChange]);

    useEffect(() => {
        const controller = new AbortController();
        void fetchPays(controller.signal);
        return () => controller.abort();
    }, [fetchPays, retryToken]);

    const locations = pays.flatMap((country) => {
        const coords = COUNTRY_COORDS[country.code];
        return coords ? [{ name: country.label, lat: coords[0], lng: coords[1] }] : [];
    });
    const connections = locations.flatMap((start, index) =>
        locations.slice(index + 1).map((end) => ({
            startLat: start.lat,
            startLng: start.lng,
            endLat: end.lat,
            endLng: end.lng,
        })),
    );

    return (
      <div className="relative isolate flex w-full flex-col items-center overflow-hidden rounded-[2rem] bg-transparent px-3 py-5 text-[var(--foreground)] shadow-[0_24px_70px_-48px_color-mix(in_oklch,var(--foreground)_35%,transparent)] sm:px-6 sm:py-7">
        <div className="flex w-full max-w-[640px] justify-end gap-3 px-2">
          <span className="inline-flex items-center gap-2 rounded-full border border-emerald-500/20 bg-emerald-500/[0.07] px-3 py-1.5 text-[10px] font-semibold uppercase tracking-[0.16em] text-emerald-700 dark:text-emerald-200">
            <span className={`h-1.5 w-1.5 rounded-full ${loading ? "bg-amber-300" : "bg-emerald-300 shadow-[0_0_10px_rgba(110,255,194,0.9)]"}`} />
            {loading ? (isFrench ? "Synchro" : "Syncing") : (isFrench ? "En direct" : "Live")}
          </span>
        </div>

        <div ref={globeContainerRef} className="relative mt-1 aspect-square w-full max-w-[640px]">
          <div className="pointer-events-none absolute inset-[8%] rounded-full border border-[color-mix(in_oklch,var(--foreground)_7%,transparent)] shadow-[0_0_70px_color-mix(in_oklch,var(--foreground)_5%,transparent)]" />
          <div className="pointer-events-none absolute inset-[14%] rounded-full border border-dashed border-[color-mix(in_oklch,var(--foreground)_8%,transparent)]" />
          <div className="absolute inset-0 flex items-center justify-center">
            <Globe
              width={globeSize}
              height={globeSize}
              backgroundColor="rgba(0,0,0,0)"
              globeImageUrl={theme === "light"
                ? "https://cdn.jsdelivr.net/npm/three-globe/example/img/earth-blue-marble.jpg"
                : "https://unpkg.com/three-globe/example/img/earth-dark.jpg"}
              showAtmosphere={true}
              atmosphereColor="#00d9ff"
              atmosphereAltitude={0.2}
              pointsData={locations}
              pointLat="lat"
              pointLng="lng"
              pointColor={() => "#73ffca"}
              pointRadius={0.55}
              arcsData={connections}
              arcStartLat="startLat"
              arcStartLng="startLng"
              arcEndLat="endLat"
              arcEndLng="endLng"
              arcColor={() => "#00eaff"}
              arcStroke={0.75}
              arcDashLength={0.35}
              arcDashGap={0.18}
              arcDashAnimateTime={2500}
              showGraticules={true}
            />
          </div>
          <span className="pointer-events-none absolute left-[9%] top-[30%] h-1.5 w-1.5 rounded-full bg-cyan-200/70 shadow-[0_0_12px_3px_rgba(0,220,255,0.45)]" />
          <span className="pointer-events-none absolute bottom-[20%] right-[12%] h-1 w-1 rounded-full bg-cyan-100/50 shadow-[0_0_10px_3px_rgba(0,220,255,0.35)]" />
        </div>
        <div className="flex w-full max-w-[640px] items-center justify-between border-t border-[color-mix(in_oklch,var(--foreground)_10%,transparent)] px-2 pt-3 text-[10px] uppercase tracking-[0.16em] text-[color-mix(in_oklch,var(--foreground)_50%,transparent)]">
          <span>{locations.length} pays</span>
          <span>{connections.length} liaisons</span>
          <span>Temps réel</span>
        </div>
        {loading && <p className="sr-only">Loading…</p>}
      </div>
    );
}
