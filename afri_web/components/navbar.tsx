"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import Image from "next/image";
import { Menu, Moon, Sun, X } from "lucide-react";
import { useUiStore } from "@/store/useUIStore";
import { Button } from "@/components/ui/button";

const navItems = {
    fr: [
        { label: "Accueil", href: "/#accueil" },
        { label: "Produit", href: "/#produit" },
        { label: "Fonctionnalité", href: "/#fonctionnalite" },
        { label: "Comment ça marche", href: "/#commentcamarche" },
        { label: "À propos", href: "/#aboutus" },
        { label: "Contact", href: "/#contactus" },
    ],
    en: [
        { label: "Home", href: "/#accueil" },
        { label: "Product", href: "/#produit" },
        { label: "Features", href: "/#fonctionnalite" },
        { label: "How it works", href: "/#commentcamarche" },
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

    useEffect(() => {
        if (!isMenuOpen) return;
        const closeOnEscape = (event: KeyboardEvent) => {
            if (event.key === "Escape") closeMenu();
        };
        window.addEventListener("keydown", closeOnEscape);
        return () => window.removeEventListener("keydown", closeOnEscape);
    }, [closeMenu, isMenuOpen]);

    const changeTheme = () => {
        const nextTheme = theme === "light" ? "dark" : "light";
        setTheme(nextTheme);
        savePreference("afrinumber-theme", nextTheme);
        document.documentElement.classList.toggle("dark", nextTheme === "dark");
    };

    const changeLanguage = () => {
        const nextLanguage = language === "fr" ? "en" : "fr";
        setLanguage(nextLanguage);
        savePreference("afrinumber-language", nextLanguage);
        document.documentElement.lang = nextLanguage;
    };

    const followLink = (href: string) => {
        closeMenu();
        if (!href.startsWith("/#")) return;
        const id = href.slice(2);
        if (window.location.pathname === "/") {
            const behavior = window.matchMedia("(prefers-reduced-motion: reduce)").matches ? "auto" : "smooth";
            window.setTimeout(() => document.getElementById(id)?.scrollIntoView({ behavior, block: "start" }), 0);
        }
    };

    const goToDownloadTarget = () => {
        closeMenu();
        if (window.location.pathname === "/") {
            const behavior = window.matchMedia("(prefers-reduced-motion: reduce)").matches ? "auto" : "smooth";
            document.getElementById("telechargement")?.scrollIntoView({ behavior, block: "start" });
            return;
        }
        router.push("/#telechargement");
    };

    const downloadLabel = language === "fr" ? "Télécharger l’App" : "Download the App";
    const controls = (
        <>
            <button
                type="button"
                onClick={changeLanguage}
                className="interactive-btn min-h-10 min-w-10 rounded-full px-3 text-xs font-bold text-foreground transition-colors duration-200 hover:bg-muted focus-visible:outline-2 focus-visible:outline-offset-2"
                aria-label={language === "fr" ? "Passer en anglais" : "Switch to French"}
            >
                {language === "fr" ? "EN" : "FR"}
            </button>
            <button
                type="button"
                onClick={changeTheme}
                className="interactive-btn group flex h-10 w-10 items-center justify-center rounded-full text-foreground transition-all duration-300 hover:bg-muted focus-visible:outline-2 focus-visible:outline-offset-2"
                aria-label={theme === "light" ? "Activer le mode sombre" : "Activer le mode clair"}
            >
                {theme === "light" ? (
                    <Moon className="h-4 w-4 transition-transform duration-300 group-hover:-rotate-12 group-hover:scale-110" />
                ) : (
                    <Sun className="h-4 w-4 transition-transform duration-300 group-hover:rotate-45 group-hover:scale-110" />
                )}
            </button>
        </>
    );

    return (
        <header className="fixed inset-x-0 top-0 z-50 w-full border-b border-border/70 bg-background/95 backdrop-blur-md transition-all duration-300">
            <div className="mx-auto flex min-h-16 w-full max-w-7xl items-center justify-between gap-4 px-4 sm:min-h-[4.5rem] sm:px-6 lg:px-8">
                <Link
                    href="/#accueil"
                    onClick={() => followLink("/#accueil")}
                    className="group flex shrink-0 items-center gap-2 text-lg font-extrabold tracking-tight text-foreground transition-transform duration-200 hover:scale-[1.02] sm:text-xl"
                >
                    {theme === "dark" ? (
                        <Image src="/images/logo-afrika-white.png" alt="AfriNumber" width={44} height={44} className="h-9 w-9 object-contain transition-transform duration-300 group-hover:rotate-3 sm:h-10 sm:w-10" />
                    ) : (
                        <Image src="/images/logo-afrika.png" alt="AfriNumber" width={44} height={44} className="h-9 w-9 object-contain transition-transform duration-300 group-hover:rotate-3 sm:h-10 sm:w-10" />
                    )}
                    <span className="tracking-tight">AfriNumber</span>
                </Link>

                <nav aria-label={language === "fr" ? "Navigation principale" : "Main navigation"} className="hidden items-center gap-1 xl:flex">
                    {items.map((item) => (
                        <Link
                            key={item.href}
                            href={item.href}
                            onClick={() => followLink(item.href)}
                            className="relative rounded-full px-3 py-2 text-sm font-semibold text-muted-foreground transition-all duration-200 hover:bg-muted/80 hover:text-foreground hover:scale-[1.02] active:scale-[0.98] focus-visible:outline-2 focus-visible:outline-offset-2"
                        >
                            {item.label}
                        </Link>
                    ))}
                </nav>

                <div className="hidden items-center gap-2 xl:flex">
                    {controls}
                    <Button
                        className="interactive-btn ml-1 bg-primary font-semibold text-primary-foreground shadow-sm hover:bg-primary/85 hover:shadow-md"
                        onClick={goToDownloadTarget}
                    >
                        {downloadLabel}
                    </Button>
                </div>

                <button
                    type="button"
                    onClick={toggleMenu}
                    className="interactive-btn flex h-11 w-11 items-center justify-center rounded-full text-foreground transition-colors hover:bg-muted focus-visible:outline-2 focus-visible:outline-offset-2 xl:hidden"
                    aria-label={isMenuOpen ? "Fermer le menu" : "Ouvrir le menu"}
                    aria-expanded={isMenuOpen}
                    aria-controls={isMenuOpen ? "mobile-navigation" : undefined}
                >
                    {isMenuOpen ? <X className="h-5 w-5 transition-transform duration-300 rotate-90" /> : <Menu className="h-5 w-5" />}
                </button>
            </div>

            {isMenuOpen && (
                <div id="mobile-navigation" className="motion-enter border-t border-border bg-background px-4 pb-6 pt-3 shadow-2xl xl:hidden">
                    <nav aria-label={language === "fr" ? "Navigation principale" : "Main navigation"} className="motion-stagger mx-auto flex max-w-7xl flex-col gap-1.5">
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
                        <div className="mt-3 flex items-center justify-between border-t border-border pt-4 px-2">
                            <span className="text-xs font-semibold text-muted-foreground">Options</span>
                            <div className="flex items-center gap-1">{controls}</div>
                        </div>
                        <Button className="mt-3 w-full bg-primary text-primary-foreground hover:bg-primary/90" onClick={goToDownloadTarget}>
                            {downloadLabel}
                        </Button>
                    </nav>
                </div>
            )}
        </header>
    );
}
