import React from "react";
import Layout from "../components/Layout";
import { Head } from "@inertiajs/react";
import styles from "./page.module.css";

type AboutProps = {
  systemVersion: string;
};

export default function About({ systemVersion }: AboutProps) {
  return (
    <Layout>
      <Head title="About" />
      <section className={styles.stack}>
        <h1 className={styles.title}>About</h1>

        <div className={styles.panel}>
          <ul className={styles.list}>
            <li>
              <span className={styles.muted}>System Version:</span> {systemVersion}
            </li>
          </ul>
        </div>
      </section>
    </Layout>
  );
}
