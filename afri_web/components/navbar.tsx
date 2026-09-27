"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import Image from "next/image";
import { Check, ChevronDown, Globe, Menu, Moon, Sun, X } from "lucide-react";
import { useUiStore } from "@/store/useUIStore";
import { Button } from "@/components/ui/button";

const navItems = {
  fr: [
    { label: "Accueil", href: "/#accueil" },
    { label: "Produit", href: "/#produit" },
    { label: "Fonctionnalité", href: "/#fonctionnalite" },
    { label: "Processus", href: "/#commentcamarche" },
    { label: "À propos", href: "/#aboutus" },
    { label: "Contact", href: "/#contactus" },
  ],
  en: [
    { label: "Home", href: "/#accueil" },
    { label: "Product", href: "/#produit" },
    { label: "Features", href: "/#fonctionnalite" },
    { label: "Process", href: "/#commentcamarche" },
    { label: "About", href: "/#aboutus" },
    { label: "Contact", href: "/#contactus" },
  ],
} as const;

function readPreference(key: string) {
  try {
    return window.localStorage.getItem(key);
  } catch {
    return null;
  }
}

function savePreference(key: string, value: string) {
  try {
    window.localStorage.setItem(key, value);
  } catch {
    // Les préférences restent actives pendant la session même si le stockage est bloqué.
  }
}

export default function Navbar() {
  const router = useRouter();
  const { isMenuOpen, toggleMenu, closeMenu, theme, language, setTheme, setLanguage } = useUiStore();
  const items = navItems[language];

  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const savedTheme = readPreference("afrinumber-theme");
    const savedLanguage = readPreference("afrinumber-language");
    const nextTheme = savedTheme === "dark" ? "dark" : "light";
    const nextLanguage = savedLanguage === "en" ? "en" : "fr";
    setTheme(nextTheme);
    setLanguage(nextLanguage);
    document.documentElement.classList.toggle("dark", nextTheme === "dark");
    document.documentElement.lang = nextLanguage;
  }, [setLanguage, setTheme]);

  // Fermer le dropdown au clic à l'extérieur
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent | TouchEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsDropdownOpen(false);
      }
    };
    if (isDropdownOpen) {
      document.addEventListener("mousedown", handleClickOutside);
      document.addEventListener("touchstart", handleClickOutside);
    }
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
      document.removeEventListener("touchstart", handleClickOutside);
    };
  }, [isDropdownOpen]);

  useEffect(() => {
    const closeOnEscape = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        closeMenu();
        setIsDropdownOpen(false);
      }
    };
    window.addEventListener("keydown", closeOnEscape);
    return () => window.removeEventListener("keydown", closeOnEscape);
  }, [closeMenu]);

  const selectTheme = (nextTheme: "light" | "dark") => {
    setTheme(nextTheme);
    savePreference("afrinumber-theme", nextTheme);
    document.documentElement.classList.toggle("dark", nextTheme === "dark");
  };

  const selectLanguage = (nextLanguage: "fr" | "en") => {
    setLanguage(nextLanguage);
    savePreference("afrinumber-language", nextLanguage);
    document.documentElement.lang = nextLanguage;
  };

  const followLink = (href: string) => {
    closeMenu();
    setIsDropdownOpen(false);
    if (!href.startsWith("/#")) return;
    const id = href.slice(2);
    if (window.location.pathname === "/") {
      const behavior = window.matchMedia("(prefers-reduced-motion: reduce)").matches ? "auto" : "smooth";
      window.setTimeout(() => document.getElementById(id)?.scrollIntoView({ behavior, block: "start" }), 0);
    }
  };

  const goToDownloadTarget = () => {
    closeMenu();
    setIsDropdownOpen(false);
    if (window.location.pathname === "/") {
      const behavior = window.matchMedia("(prefers-reduced-motion: reduce)").matches ? "auto" : "smooth";
      document.getElementById("telechargement")?.scrollIntoView({ behavior, block: "start" });
      return;
    }
    router.push("/#telechargement");
  };

  const downloadLabel = language === "fr" ? "Télécharger l’App" : "Download the App";

  return (
    <header className="fixed inset-x-0 top-0 z-50 w-full border-b border-border/70 bg-background/95 backdrop-blur-md transition-all duration-300">
      {/* Conteneur 95% de la largeur écran avec centrage parfait de la navigation */}
      <div className="mx-auto flex min-h-16 w-[95%] max-w-[1700px] items-center justify-between gap-4 px-2 sm:min-h-[4.5rem] sm:px-4 xl:grid xl:grid-cols-[auto_1fr_auto]">
        {/* Extrémité Gauche : Logo */}
        <div className="flex items-center justify-start">
          <Link
            href="/#accueil"
            onClick={() => followLink("/#accueil")}
            className="group flex shrink-0 items-center gap-2.5 text-lg font-extrabold tracking-tight text-foreground transition-transform duration-200 hover:scale-[1.02] sm:text-xl"
          >
            {theme === "dark" ? (
              <Image
                src="/images/logo-afrika-white.png"
                alt="AfriNumber"
                width={44}
                height={44}
                className="h-9 w-9 object-contain transition-transform duration-300 group-hover:rotate-3 sm:h-10 sm:w-10"
              />
            ) : (
              <Image
                src="/images/logo-afrika.png"
                alt="AfriNumber"
                width={44}
                height={44}
                className="h-9 w-9 object-contain transition-transform duration-300 group-hover:rotate-3 sm:h-10 sm:w-10"
              />
            )}
            <span className="tracking-tight">AfriNumber</span>
          </Link>
        </div>

        {/* Milieu : Navigation centrée */}
        <nav
          aria-label={language === "fr" ? "Navigation principale" : "Main navigation"}
          className="hidden items-center justify-center gap-1 xl:flex"
        >
          {items.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              onClick={() => followLink(item.href)}
              className="relative rounded-full px-3.5 py-2 text-sm font-semibold text-muted-foreground transition-all duration-200 hover:bg-muted/80 hover:text-foreground hover:scale-[1.02] active:scale-[0.98] focus-visible:outline-2 focus-visible:outline-offset-2"
            >
              {item.label}
            </Link>
          ))}
        </nav>

        {/* Extrémité Droite : Dropdown Langue/Thème & Bouton Télécharger */}
        <div className="hidden items-center justify-end gap-3 xl:flex">
          {/* Dropdown Button pour Langue & Thème */}
          <div className="relative" ref={dropdownRef}>
            <button
              type="button"
              onClick={() => setIsDropdownOpen((prev) => !prev)}
              aria-expanded={isDropdownOpen}
              aria-haspopup="true"
              aria-label={language === "fr" ? "Paramètres de langue et thème" : "Language and theme settings"}
              className="interactive-btn flex items-center gap-2 rounded-full border border-border/80 bg-background/80 px-3.5 py-2 text-xs font-semibold text-foreground shadow-xs backdrop-blur-sm transition-all duration-200 hover:border-border hover:bg-muted/80 focus-visible:outline-2 focus-visible:outline-offset-2"
            >
              <span className="flex items-center gap-1.5 font-bold uppercase tracking-wider">
                <Globe className="h-3.5 w-3.5 opacity-70" />
                {language === "fr" ? "FR" : "EN"}
              </span>
              <span className="h-3 w-px bg-border/80" />
              <span className="flex items-center justify-center">
                {theme === "dark" ? (
                  <Moon className="h-3.5 w-3.5 text-foreground" />
                ) : (
                  <Sun className="h-3.5 w-3.5 text-foreground" />
                )}
              </span>
              <ChevronDown
                className={`h-3.5 w-3.5 opacity-60 transition-transform duration-300 ${
                  isDropdownOpen ? "rotate-180" : ""
                }`}
              />
            </button>

            {/* Menu Dropdown encadré */}
            {isDropdownOpen && (
              <div
                role="menu"
                className="motion-enter absolute right-0 top-full mt-2 w-60 origin-top-right rounded-2xl border border-border/90 bg-background/95 p-2.5 shadow-2xl backdrop-blur-xl transition-all"
              >
                {/* Section Langue */}
                <div className="px-2.5 py-1.5 text-[11px] font-semibold uppercase tracking-wider text-muted-foreground">
                  {language === "fr" ? "Langue" : "Language"}
                </div>
                <div className="flex flex-col gap-1">
                  <button
                    type="button"
                    onClick={() => {
                      selectLanguage("fr");
                    }}
                    className={`flex w-full items-center justify-between rounded-xl px-3 py-2 text-xs font-medium transition-colors ${
                      language === "fr"
                        ? "bg-primary/10 text-primary font-semibold"
                        : "text-foreground hover:bg-muted"
                    }`}
                  >
                    <span className="flex items-center gap-2">
                      <span className="text-sm">🇫🇷</span>
                      <span>Français</span>
                    </span>
                    {language === "fr" && <Check className="h-3.5 w-3.5" />}
                  </button>

                  <button
                    type="button"
                    onClick={() => {
                      selectLanguage("en");
                    }}
                    className={`flex w-full items-center justify-between rounded-xl px-3 py-2 text-xs font-medium transition-colors ${
                      language === "en"
                        ? "bg-primary/10 text-primary font-semibold"
                        : "text-foreground hover:bg-muted"
                    }`}
                  >
                    <span className="flex items-center gap-2">
                      <span className="text-sm">🇬🇧</span>
                      <span>English</span>
                    </span>
                    {language === "en" && <Check className="h-3.5 w-3.5" />}
                  </button>
                </div>

                <div className="my-2 border-t border-border/70" />

                {/* Section Thème */}
                <div className="px-2.5 py-1.5 text-[11px] font-semibold uppercase tracking-wider text-muted-foreground">
                  {language === "fr" ? "Apparence" : "Appearance"}
                </div>
                <div className="flex flex-col gap-1">
                  <button
                    type="button"
                    onClick={() => {
                      selectTheme("light");
                    }}
                    className={`flex w-full items-center justify-between rounded-xl px-3 py-2 text-xs font-medium transition-colors ${
                      theme === "light"
                        ? "bg-primary/10 text-primary font-semibold"
                        : "text-foreground hover:bg-muted"
                    }`}
                  >
                    <span className="flex items-center gap-2">
                      <Sun className="h-3.5 w-3.5" />
                      <span>{language === "fr" ? "Mode Clair" : "Light Mode"}</span>
                    </span>
                    {theme === "light" && <Check className="h-3.5 w-3.5" />}
                  </button>

                  <button
                    type="button"
                    onClick={() => {
                      selectTheme("dark");
                    }}
                    className={`flex w-full items-center justify-between rounded-xl px-3 py-2 text-xs font-medium transition-colors ${
                      theme === "dark"
                        ? "bg-primary/10 text-primary font-semibold"
                        : "text-foreground hover:bg-muted"
                    }`}
                  >
                    <span className="flex items-center gap-2">
                      <Moon className="h-3.5 w-3.5" />
                      <span>{language === "fr" ? "Mode Sombre" : "Dark Mode"}</span>
                    </span>
                    {theme === "dark" && <Check className="h-3.5 w-3.5" />}
                  </button>
                </div>
              </div>
            )}
          </div>

          <Button
            className="interactive-btn bg-primary font-semibold text-primary-foreground shadow-sm hover:bg-primary/85 hover:shadow-md"
            onClick={goToDownloadTarget}
          >
            {downloadLabel}
          </Button>
        </div>

        {/* Bouton Hamburger Mobile */}
        <button
          type="button"
          onClick={toggleMenu}
          className="interactive-btn flex h-11 w-11 items-center justify-center rounded-full text-foreground transition-colors hover:bg-muted focus-visible:outline-2 focus-visible:outline-offset-2 xl:hidden"
          aria-label={isMenuOpen ? "Fermer le menu" : "Ouvrir le menu"}
          aria-expanded={isMenuOpen}
          aria-controls={isMenuOpen ? "mobile-navigation" : undefined}
        >
          {isMenuOpen ? (
            <X className="h-5 w-5 transition-transform duration-300 rotate-90" />
          ) : (
            <Menu className="h-5 w-5" />
          )}
        </button>
      </div>

      {/* Menu Mobile */}
      {isMenuOpen && (
        <div
          id="mobile-navigation"
          className="motion-enter border-t border-border bg-background px-4 pb-6 pt-3 shadow-2xl xl:hidden"
        >
          <nav
            aria-label={language === "fr" ? "Navigation principale" : "Main navigation"}
            className="motion-stagger mx-auto flex w-[95%] max-w-[1700px] flex-col gap-1.5"
          >
            {items.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                onClick={() => followLink(item.href)}
                className="rounded-xl px-4 py-3 text-base font-semibold text-foreground transition-all duration-200 hover:bg-muted hover:translate-x-1"
              >
                {item.label}
              </Link>
            ))}

            {/* Options Langue & Thème dans le menu mobile */}
            <div className="mt-3 flex flex-col gap-3 rounded-2xl border border-border/80 bg-muted/30 p-3.5">
              <div className="flex items-center justify-between">
                <span className="text-xs font-semibold text-muted-foreground">
                  {language === "fr" ? "Langue" : "Language"}
                </span>
                <div className="flex items-center gap-1">
                  <button
                    type="button"
                    onClick={() => selectLanguage("fr")}
                    className={`rounded-full px-3 py-1 text-xs font-bold transition-colors ${
                      language === "fr"
                        ? "bg-primary text-primary-foreground"
                        : "bg-background text-foreground border border-border"
                    }`}
                  >
                    FR
                  </button>
                  <button
                    type="button"
                    onClick={() => selectLanguage("en")}
                    className={`rounded-full px-3 py-1 text-xs font-bold transition-colors ${
                      language === "en"
                        ? "bg-primary text-primary-foreground"
                        : "bg-background text-foreground border border-border"
                    }`}
                  >
                    EN
                  </button>
                </div>
              </div>

              <div className="flex items-center justify-between border-t border-border/60 pt-2.5">
                <span className="text-xs font-semibold text-muted-foreground">
                  {language === "fr" ? "Thème" : "Theme"}
                </span>
                <div className="flex items-center gap-1">
                  <button
                    type="button"
                    onClick={() => selectTheme("light")}
                    className={`flex h-8 items-center gap-1.5 rounded-full px-3 text-xs font-semibold transition-colors ${
                      theme === "light"
                        ? "bg-primary text-primary-foreground"
                        : "bg-background text-foreground border border-border"
                    }`}
                  >
                    <Sun className="h-3.5 w-3.5" />
                    <span>{language === "fr" ? "Clair" : "Light"}</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => selectTheme("dark")}
                    className={`flex h-8 items-center gap-1.5 rounded-full px-3 text-xs font-semibold transition-colors ${
                      theme === "dark"
                        ? "bg-primary text-primary-foreground"
                        : "bg-background text-foreground border border-border"
                    }`}
                  >
                    <Moon className="h-3.5 w-3.5" />
                    <span>{language === "fr" ? "Sombre" : "Dark"}</span>
                  </button>
                </div>
              </div>
            </div>

            <Button
              className="mt-3 w-full bg-primary text-primary-foreground hover:bg-primary/90"
              onClick={goToDownloadTarget}
            >
              {downloadLabel}
            </Button>
          </nav>
        </div>
      )}
    </header>
  );
}
