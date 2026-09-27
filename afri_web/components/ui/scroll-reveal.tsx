"use client";

import React, { useEffect, useRef, useState } from "react";

interface ScrollRevealProps {
  children: React.ReactNode;
  className?: string;
  animation?: "fade-up" | "fade-in" | "scale-up" | "slide-left" | "slide-right";
  delay?: number; // in ms
  threshold?: number;
  once?: boolean;
}

export default function ScrollReveal({
  children,
  className = "",
  animation = "fade-up",
  delay = 0,
  threshold = 0.1,
  once = true,
}: ScrollRevealProps) {
  const ref = useRef<HTMLDivElement>(null);
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    // If user prefers reduced motion, show immediately
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      setIsVisible(true);
      return;
    }

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setIsVisible(true);
          if (once) {
            observer.unobserve(el);
          }
        } else if (!once) {
          setIsVisible(false);
        }
      },
      {
        threshold,
        rootMargin: "0px 0px -40px 0px",
      }
    );

    observer.observe(el);

    return () => {
      observer.disconnect();
    };
  }, [threshold, once]);

  const getAnimationClass = () => {
    switch (animation) {
      case "fade-in":
        return isVisible ? "opacity-100 translate-y-0" : "opacity-0";
      case "scale-up":
        return isVisible
          ? "opacity-100 scale-100 translate-y-0"
          : "opacity-0 scale-[0.96] translate-y-4";
      case "slide-left":
        return isVisible ? "opacity-100 translate-x-0" : "opacity-0 translate-x-6";
      case "slide-right":
        return isVisible ? "opacity-100 translate-x-0" : "opacity-0 -translate-x-6";
      case "fade-up":
      default:
        return isVisible ? "opacity-100 translate-y-0" : "opacity-0 translate-y-6";
    }
  };

  return (
    <div
      ref={ref}
      style={{
        transitionDelay: `${delay}ms`,
        transitionDuration: "650ms",
        transitionTimingFunction: "cubic-bezier(0.16, 1, 0.3, 1)",
      }}
      className={`transition-all will-change-transform ${getAnimationClass()} ${className}`}
    >
      {children}
    </div>
  );
}
