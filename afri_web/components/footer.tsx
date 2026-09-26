"use client";

import { Globe } from "lucide-react";
import { useUiStore } from "@/store/useUIStore";

export default function Footer() {
  const language = useUiStore((state) => state.language);
  const isFrench = language === "fr";

  return (
    <footer className="border-t border-border bg-background text-muted-foreground">
      <div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
        <div className="flex flex-col items-center justify-between gap-6 md:flex-row">
          
          {/* Section Identité */}
          <div className="flex flex-col items-center gap-2 md:items-start">
            <div className="flex items-center gap-2 text-lg font-bold text-foreground">
              <Globe className="h-5 w-5 text-blue-600" />
              <span>AfriNumber</span>
            </div>
            <p className="text-center text-xs text-stone-500 md:text-left">
              {isFrench
                ? "Solution d'inclusion numérique pour les entrepreneurs d'Afrique."
                : "Digital inclusion for African entrepreneurs."}
            </p>
          </div>

          {/* Rappel Fintech & Stack */}
          <div className="text-center text-xs text-stone-400 md:text-right">
            <p>
              {isFrench
                ? "Paiements locaux sécurisés via MTN MoMo, Airtel Money & Mvola."
                : "Secure local payments via MTN MoMo, Airtel Money & Mvola."}
            </p>
            <p className="mt-1">
              {isFrench
                ? "Propulsé par Laravel, Supabase, Twilio & OpenAI."
                : "Powered by Laravel, Supabase, Twilio & OpenAI."}
            </p>
          </div>
        </div>

        {/* Copyright */}
        <div className="mt-8 border-t border-border pt-6 text-center text-xs text-muted-foreground">
          &copy; {new Date().getFullYear()} AfriNumber. {isFrench
            ? "Développé pour le Hackathon. Tous droits réservés."
            : "Built for the Hackathon. All rights reserved."}
        </div>
      </div>
    </footer>
  );
}
