import React from "react";
import { createInertiaApp } from "@inertiajs/react";
import { createRoot } from "react-dom/client";
import "./styles/global.css";

const pages = import.meta.glob<{ default: React.ComponentType<any> }>("./pages/**/*.tsx");

createInertiaApp({
  async resolve(name) {
    const page = pages[`./pages/${name}.tsx`];

    if (!page) {
      throw new Error(`Page not found: ${name}`);
    }

    return (await page()).default;
  },
  setup({ el, App, props }) {
    // Base UI assumes "root" class
    createRoot(el).render(
      <div className="root">
        <App {...props} />
      </div>,
    );
  },
});
