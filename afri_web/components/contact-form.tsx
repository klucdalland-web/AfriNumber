"use client";

import { useState } from "react";
import { useUiStore } from "@/store/useUIStore";

export default function ContactForm() {
  const language = useUiStore((state) => state.language);
  const [emailDraft, setEmailDraft] = useState("");
  const isFrench = language === "fr";
  const copy = isFrench
    ? {
        eyebrow: "Contact",
        title: "Parlons de votre projet.",
        description: "Une question sur AfriNumber ? Envoyez-nous un message, notre équipe vous répondra rapidement.",
        name: "Nom",
        email: "E-mail",
        subject: "Objet",
        message: "Message",
        namePlaceholder: "Votre nom",
        emailPlaceholder: "vous@exemple.com",
        subjectPlaceholder: "Comment pouvons-nous vous aider ?",
        messagePlaceholder: "Écrivez votre message...",
        submit: "Préparer le message",
        ready: "Votre message est prêt. Utilisez le lien pour l’envoyer depuis votre messagerie.",
        openEmail: "Ouvrir le client e-mail",
      }
    : {
        eyebrow: "Contact",
        title: "Let’s talk about your project.",
        description: "Have a question about AfriNumber? Send us a message and our team will get back to you soon.",
        name: "Name",
        email: "Email",
        subject: "Subject",
        message: "Message",
        namePlaceholder: "Your name",
        emailPlaceholder: "you@example.com",
        subjectPlaceholder: "How can we help?",
        messagePlaceholder: "Write your message...",
        submit: "Prepare message",
        ready: "Your message is ready. Use the link to send it from your email app.",
        openEmail: "Open your email app",
      };

  const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const data = new FormData(event.currentTarget);
    const name = String(data.get("name") ?? "").trim();
    const email = String(data.get("email") ?? "").trim();
    const subject = String(data.get("subject") ?? "").trim();
    const message = String(data.get("message") ?? "").trim();
    const body = [
      `${isFrench ? "Nom" : "Name"}: ${name}`,
      `${isFrench ? "E-mail" : "Email"}: ${email}`,
      "",
      message,
    ].join("\n");

    setEmailDraft(
      `mailto:contact@afrinumber.com?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`,
    );
  };

  return (
    <section id="contactus" className="relative overflow-hidden section-padding scroll-mt-24">
      <div className="section-container">
        <div className="grid w-full gap-10 lg:grid-cols-[0.8fr_1.2fr] lg:items-start lg:gap-16 xl:gap-20">
          <div className="max-w-xl">
            <span className="section-eyebrow">
              <span className="h-1.5 w-1.5 rounded-full bg-current" />
              {copy.eyebrow}
            </span>
            <h2 className="section-title text-left mt-4">{copy.title}</h2>
            <p className="mt-5 max-w-md text-[15.5px] sm:text-base leading-relaxed text-[color-mix(in_oklch,var(--foreground)_60%,transparent)]">
              {copy.description}
            </p>
          </div>

          <form
            onSubmit={handleSubmit}
            onChange={() => setEmailDraft("")}
            className="grid gap-5 rounded-[1.75rem] border border-[color-mix(in_oklch,var(--foreground)_10%,transparent)] bg-[color-mix(in_oklch,var(--foreground)_3.5%,var(--background))] p-6 sm:p-8 lg:p-10 shadow-sm transition-all duration-300 hover:shadow-md"
          >
            <div className="grid gap-5 sm:grid-cols-2">
              <label className="grid gap-2 text-sm font-medium">
                {copy.name}
                <input
                  name="name"
                  type="text"
                  autoComplete="name"
                  required
                  placeholder={copy.namePlaceholder}
                  className="min-h-11 rounded-xl border border-input bg-background px-4 text-sm outline-none transition-all duration-200 focus:border-ring focus:ring-2 focus:ring-ring/20"
                />
              </label>
              <label className="grid gap-2 text-sm font-medium">
                {copy.email}
                <input
                  name="email"
                  type="email"
                  autoComplete="email"
                  required
                  placeholder={copy.emailPlaceholder}
                  className="min-h-11 rounded-xl border border-input bg-background px-4 text-sm outline-none transition-all duration-200 focus:border-ring focus:ring-2 focus:ring-ring/20"
                />
              </label>
            </div>
            <label className="grid gap-2 text-sm font-medium">
              {copy.subject}
              <input
                name="subject"
                type="text"
                required
                placeholder={copy.subjectPlaceholder}
                className="min-h-11 rounded-xl border border-input bg-background px-4 text-sm outline-none transition-all duration-200 focus:border-ring focus:ring-2 focus:ring-ring/20"
              />
            </label>
            <label className="grid gap-2 text-sm font-medium">
              {copy.message}
              <textarea
                name="message"
                required
                rows={5}
                placeholder={copy.messagePlaceholder}
                className="resize-y rounded-xl border border-input bg-background px-4 py-3 text-sm outline-none transition-all duration-200 focus:border-ring focus:ring-2 focus:ring-ring/20"
              />
            </label>
            <div className="flex flex-col items-start gap-3 sm:flex-row sm:items-center sm:justify-between pt-2">
              <button
                type="submit"
                className="interactive-btn inline-flex min-h-11 items-center justify-center rounded-full bg-primary px-8 text-sm font-semibold text-primary-foreground shadow-sm hover:bg-primary/90 hover:shadow-md"
              >
                {copy.submit}
              </button>
              {emailDraft && (
                <div role="status" className="motion-enter text-sm">
                  <p className="text-emerald-600 dark:text-emerald-400 font-medium">{copy.ready}</p>
                  <a className="mt-1 inline-block font-semibold underline underline-offset-4 text-primary hover:opacity-80" href={emailDraft}>{copy.openEmail}</a>
                </div>
              )}
            </div>
          </form>
        </div>
      </div>
    </section>
  );
}
