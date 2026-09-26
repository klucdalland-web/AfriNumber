"use client";

// components/faqaccordion.tsx , AfriNumber
import { useMemo, useState } from "react";
import { useUiStore } from "@/store/useUIStore";

type FaqItem = {
  id: string;
  category: { fr: string; en: string };
  question: { fr: string; en: string };
  answer: { fr: string; en: string };
};

const faqItems: FaqItem[] = [
  {
    id: "q1",
    category: { fr: "Général", en: "General" },
    question: {
      fr: "Qu'est-ce qu'AfriNumber ?",
      en: "What is AfriNumber?",
    },
    answer: {
      fr: "AfriNumber est un service qui vous permet d'obtenir un numéro de téléphone international (États-Unis, France, Canada, Royaume-Uni…) payable directement en Mobile Money, sans carte bancaire internationale , idéal pour les freelances, entrepreneurs et PME du Congo et de Madagascar.",
      en: "AfriNumber is a service allowing you to get an international phone number (USA, France, Canada, UK, etc.) payable directly with Mobile Money without needing an international bank card — perfect for freelancers, entrepreneurs, and SMEs in Africa.",
    },
  },
  {
    id: "q2",
    category: { fr: "Général", en: "General" },
    question: {
      fr: "Dans quels pays le service est-il disponible ?",
      en: "In which countries is the service available?",
    },
    answer: {
      fr: "AfriNumber est actuellement disponible au Congo et à Madagascar. La liste des pays couverts s'affiche en temps réel sur la page « À propos », et s'élargit progressivement.",
      en: "AfriNumber is currently available in Congo and Madagascar. The list of supported countries is displayed in real time on our About page and is steadily expanding.",
    },
  },
  {
    id: "q3",
    category: { fr: "Général", en: "General" },
    question: {
      fr: "Ai-je besoin d'une carte bancaire pour utiliser AfriNumber ?",
      en: "Do I need a credit card to use AfriNumber?",
    },
    answer: {
      fr: "Non. C'est justement le principe d'AfriNumber : tous les paiements se font via Mobile Money (MTN MoMo, Airtel Money, Mvola), sans carte Visa ou Mastercard.",
      en: "No. That is precisely what AfriNumber solves: all payments are handled via local Mobile Money (MTN MoMo, Airtel Money, Mvola) without Visa or Mastercard.",
    },
  },
  {
    id: "q4",
    category: { fr: "Paiement", en: "Payment" },
    question: {
      fr: "Quels moyens de paiement sont acceptés ?",
      en: "Which payment methods are accepted?",
    },
    answer: {
      fr: "MTN MoMo, Airtel Money et Mvola, selon votre pays. D'autres opérateurs Mobile Money pourront être ajoutés à l'avenir.",
      en: "MTN MoMo, Airtel Money, and Mvola, depending on your region. Additional Mobile Money operators are continuously being onboarded.",
    },
  },
  {
    id: "q5",
    category: { fr: "Paiement", en: "Payment" },
    question: {
      fr: "Le paiement est-il sécurisé ?",
      en: "Is the payment safe and secure?",
    },
    answer: {
      fr: "Oui. Les paiements sont traités directement par votre opérateur Mobile Money ; AfriNumber ne stocke jamais votre code secret ni vos identifiants de paiement.",
      en: "Yes. Transactions are processed directly by your Mobile Money operator; AfriNumber never stores your secret PIN code or payment credentials.",
    },
  },
  {
    id: "q6",
    category: { fr: "Paiement", en: "Payment" },
    question: {
      fr: "Puis-je me faire rembourser après l'activation d'un numéro ?",
      en: "Can I get a refund after a number is activated?",
    },
    answer: {
      fr: "Sauf cas particulier prévu par nos conditions générales d'utilisation, les sommes versées ne sont pas remboursables une fois le numéro activé. Contactez le support si vous rencontrez un problème.",
      en: "Unless otherwise specified in our Terms of Service, fees are non-refundable once a number is activated. Feel free to contact our support team for any inquiries.",
    },
  },
  {
    id: "q7",
    category: { fr: "Numéros & SMS", en: "Numbers & SMS" },
    question: {
      fr: "Comment fonctionne la traduction automatique des SMS ?",
      en: "How does automated AI SMS translation work?",
    },
    answer: {
      fr: "Chaque SMS reçu sur votre numéro AfriNumber est analysé par un moteur d'intelligence artificielle qui le traduit automatiquement dans votre langue, en quelques secondes, directement dans l'application.",
      en: "Every SMS received on your AfriNumber is processed by an integrated AI engine that translates it into your preferred language in seconds directly in the app.",
    },
  },
  {
    id: "q8",
    category: { fr: "Numéros & SMS", en: "Numbers & SMS" },
    question: {
      fr: "Qu'est-ce que le mode Zéro Data ?",
      en: "What is Zero Data Mode?",
    },
    answer: {
      fr: "Le mode Zéro Data permet de recevoir vos appels et SMS via un renvoi d'appel GSM classique, sans connexion internet , pensé pour les zones où le réseau data est instable ou coûteux.",
      en: "Zero Data Mode enables receiving calls and SMS messages through direct GSM forwarding without requiring internet access — tailored for unstable data zones.",
    },
  },
  {
    id: "q9",
    category: { fr: "Numéros & SMS", en: "Numbers & SMS" },
    question: {
      fr: "Puis-je changer de pays après avoir acheté un numéro ?",
      en: "Can I switch countries after purchasing a number?",
    },
    answer: {
      fr: "Vous pouvez à tout moment acheter un numéro supplémentaire dans un autre pays. Un même numéro reste toutefois rattaché au pays pour lequel il a été émis.",
      en: "You can purchase additional numbers in other countries at any time. An existing number remains attached to the country for which it was issued.",
    },
  },
  {
    id: "q10",
    category: { fr: "Sécurité", en: "Security" },
    question: {
      fr: "Comment mes documents KYC sont-ils protégés ?",
      en: "How are my KYC identity documents secured?",
    },
    answer: {
      fr: "Vos documents d'identité sont chiffrés et analysés par un système de vérification automatisé, avec un accès strictement limité. Consultez notre politique de confidentialité pour le détail des durées de conservation.",
      en: "Your identity documents are encrypted and analyzed by an automated verification system with strict access controls following international data privacy rules.",
    },
  },
  {
    id: "q11",
    category: { fr: "Sécurité", en: "Security" },
    question: {
      fr: "Que faire si je soupçonne une fraude sur mon compte ?",
      en: "What should I do if I suspect fraud on my account?",
    },
    answer: {
      fr: "Contactez immédiatement le support via WhatsApp ou e-mail. AfriNumber intègre un pare-feu IA qui surveille en continu les tentatives d'usage frauduleux.",
      en: "Contact support immediately via WhatsApp or email. AfriNumber incorporates an AI anti-fraud firewall that continuously monitors unauthorized activity.",
    },
  },
  {
    id: "q12",
    category: { fr: "Support", en: "Support" },
    question: {
      fr: "Comment contacter le support AfriNumber ?",
      en: "How do I reach AfriNumber support?",
    },
    answer: {
      fr: "Par e-mail à contact@afrinumber.com ou via WhatsApp , les deux options sont disponibles en pied de page. Notre équipe répond en général en moins de 24h.",
      en: "By emailing contact@afrinumber.com or via WhatsApp — both options are accessible in the footer. Our team usually responds within 24 hours.",
    },
  },
];

const normalizeSearchText = (value: string) =>
  value.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLocaleLowerCase("fr");

function IconChevron() {
  return (
    <svg viewBox="0 0 24 24" fill="none" className="w-4 h-4" strokeWidth={1.8} stroke="currentColor">
      <path d="M6 9.5 12 15.5 18 9.5" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function IconSearch() {
  return (
    <svg viewBox="0 0 24 24" fill="none" className="w-[18px] h-[18px]" strokeWidth={1.5} stroke="currentColor">
      <circle cx="10.5" cy="10.5" r="6.5" strokeLinecap="round" strokeLinejoin="round" />
      <path d="M19 19 15.2 15.2" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

export default function FaqAccordion() {
  const language = useUiStore((state) => state.language);
  const langKey = language === "en" ? "en" : "fr";
  const allCategoryLabel = langKey === "en" ? "All" : "Tout";

  const [query, setQuery] = useState("");
  const [category, setCategory] = useState("all");
  const [openIds, setOpenIds] = useState<Set<string>>(new Set());

  const categories = useMemo(() => {
    const rawSet = new Set(faqItems.map((f) => f.category[langKey]));
    return [{ key: "all", label: allCategoryLabel }, ...Array.from(rawSet).map((c) => ({ key: c, label: c }))];
  }, [langKey, allCategoryLabel]);

  const filtered = useMemo(() => {
    const q = normalizeSearchText(query.trim());
    return faqItems.filter((item) => {
      const itemCat = item.category[langKey];
      const matchesCategory = category === "all" || itemCat === category;
      const qText = item.question[langKey];
      const aText = item.answer[langKey];
      const matchesQuery =
        q.length === 0 ||
        normalizeSearchText(qText).includes(q) ||
        normalizeSearchText(aText).includes(q);
      return matchesCategory && matchesQuery;
    });
  }, [query, category, langKey]);

  const toggle = (id: string) => {
    setOpenIds((prev) => {
      const next = new Set(prev);
      next.has(id) ? next.delete(id) : next.add(id);
      return next;
    });
  };

  return (
    <div>
      {/* Recherche */}
      <div className="relative mx-auto max-w-xl">
        <span className="pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 text-[color-mix(in_oklch,var(--foreground)_45%,transparent)]">
          <IconSearch />
        </span>
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          aria-label={langKey === "en" ? "Search FAQ" : "Rechercher dans la FAQ"}
          placeholder={langKey === "en" ? "Search a question…" : "Rechercher une question…"}
          className="w-full rounded-full border border-[color-mix(in_oklch,var(--foreground)_14%,transparent)] bg-[var(--background)] py-3 pl-11 pr-4 text-[14.5px] text-[var(--foreground)] outline-none transition-all duration-300 ease-out placeholder:text-[color-mix(in_oklch,var(--foreground)_40%,transparent)] focus:border-[var(--foreground)] focus:ring-2 focus:ring-[color-mix(in_oklch,var(--foreground)_15%,transparent)]"
        />
      </div>

      {/* Filtres par catégorie */}
      <div className="mt-6 flex flex-wrap items-center justify-center gap-2">
        {categories.map((cat) => (
          <button
            type="button"
            key={cat.key}
            onClick={() => setCategory(cat.key)}
            className={`interactive-btn rounded-full border px-4 py-1.5 text-[13px] font-medium tracking-tight transition-all duration-200 ease-out ${
              category === cat.key
                ? "border-[var(--foreground)] bg-[var(--foreground)] text-[var(--background)] shadow-sm"
                : "border-[color-mix(in_oklch,var(--foreground)_14%,transparent)] text-[color-mix(in_oklch,var(--foreground)_65%,transparent)] hover:border-[color-mix(in_oklch,var(--foreground)_30%,transparent)] hover:bg-[color-mix(in_oklch,var(--foreground)_4%,var(--background))]"
            }`}
          >
            {cat.label}
          </button>
        ))}
      </div>

      {/* Liste */}
      <div className="mx-auto mt-10 max-w-3xl">
        {filtered.length === 0 ? (
          <p className="py-10 text-center text-[14.5px] text-[color-mix(in_oklch,var(--foreground)_55%,transparent)]">
            {langKey === "en" ? "No questions match your search." : "Aucune question ne correspond à votre recherche."}
          </p>
        ) : (
          <ul className="flex flex-col gap-3">
            {filtered.map((item) => {
              const isOpen = openIds.has(item.id);
              return (
                <li
                  key={item.id}
                  className={`overflow-hidden rounded-[1.5rem] border transition-all duration-300 ease-out ${
                    isOpen
                      ? "border-[color-mix(in_oklch,var(--foreground)_25%,transparent)] bg-[color-mix(in_oklch,var(--foreground)_5%,var(--background))] shadow-sm"
                      : "border-[color-mix(in_oklch,var(--foreground)_10%,transparent)] bg-[color-mix(in_oklch,var(--foreground)_3%,var(--background))] hover:border-[color-mix(in_oklch,var(--foreground)_20%,transparent)] hover:bg-[color-mix(in_oklch,var(--foreground)_4%,var(--background))]"
                  }`}
                >
                  <button
                    type="button"
                    onClick={() => toggle(item.id)}
                    aria-expanded={isOpen}
                    aria-controls={`answer-${item.id}`}
                    className="flex w-full items-center justify-between gap-4 px-6 py-5 text-left transition-colors"
                  >
                    <span className="text-[15px] sm:text-[15.5px] font-medium tracking-tight text-[var(--foreground)]">
                      {item.question[langKey]}
                    </span>
                    <span
                      className={`flex-shrink-0 text-[color-mix(in_oklch,var(--foreground)_55%,transparent)] transition-transform duration-300 ease-out ${
                        isOpen ? "rotate-180 text-[var(--foreground)]" : ""
                      }`}
                    >
                      <IconChevron />
                    </span>
                  </button>
                  <div
                    id={`answer-${item.id}`}
                    aria-hidden={!isOpen}
                    className={`grid transition-all duration-300 ease-out ${
                      isOpen ? "grid-rows-[1fr] opacity-100" : "grid-rows-[0fr] opacity-0"
                    }`}
                  >
                    <div className="overflow-hidden">
                      <p className="px-6 pb-5 text-[14.5px] sm:text-[15px] leading-relaxed text-[color-mix(in_oklch,var(--foreground)_65%,transparent)]">
                        {item.answer[langKey]}
                      </p>
                    </div>
                  </div>
                </li>
              );
            })}
          </ul>
        )}
      </div>
    </div>
  );
}
