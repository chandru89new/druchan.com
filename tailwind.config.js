/** @type {import('tailwindcss').Config} */
const colors = require("tailwindcss/colors");
module.exports = {
  content: ["./src/**/*.elm", "./public/index.html"],
  theme: {
    extend: {
      colors: {
        zinc: {
          ...colors.zinc,
          400: "var(--zinc-400)",
        },
        slate: {
          ...colors.slate,
          800: "var(--slate-800)",
        },
        stone: {
          ...colors.stone,
          500: "var(--stone-500)",
          800: "var(--stone-800)",
        },
      },
    },
  },
  plugins: [],
};
