import { Link } from "@inertiajs/react";
import React from "react";
import { Head } from "@inertiajs/react";
import Layout from "../components/Layout";
import styles from "./page.module.css";

export default function Home() {
  return (
    <Layout>
      <Head title="Demo Home" />

      <section className={styles.stack}>
        <h1 className={styles.title}>Demo</h1>

        <nav className={styles.panel} aria-label="Demo pages">
          <ul className={styles.list}>
            <li>
              <Link href="/about">About</Link>
            </li>
          </ul>
        </nav>
      </section>
    </Layout>
  );
}
