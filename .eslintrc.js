module.exports = {
  env: {
    browser: false,
    es6: true,
    node: false,
    jest: true,
  },
  extends: [
    'airbnb-typescript-prettier',
    'plugin:react/recommended',
    'plugin:import/typescript',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaFeatures: {
      jsx: true,
    },
    ecmaVersion: 2018,
    project: './tsconfig.json',
    tsConfigRootDir: './',
    sourceType: 'module',
  },
  plugins: ['react', '@typescript-eslint', 'import'],
  ignorePatterns: ['.eslintrc.js'],
  settings: {
    react: {
      version: 'detect',
    },
    'import/resolver': {
      typescript: {},
      node: {
        paths: ['src'],
        extensions: ['.js', '.ts', '.jsx', '.tsx'],
      },
    },
  },
  rules: {
    quotes: ['error', 'single', { avoidEscape: true }],
    indent: 0,
    "no-restricted-exports": 0,
    'no-underscore-dangle': ['error', { allow: ['_retry'] }],
    'comma-dangle': [2, 'always-multiline'],
    'lines-between-class-members': 0,
    'object-curly-newline': 0,
    'import/extensions': [
      'error',
      'ignorePackages',
      {
        ts: 'never',
        tsx: 'never',
      },
    ],
    'import/no-extraneous-dependencies': [
      'error',
      { devDependencies: ['**/*.test.*', '**/*.spec.*', 'buildconfig/**'] },
    ],
    'import/no-useless-path-segments': [
      'error',
      {
        noUselessIndex: true,
      },
    ],
    'import/order': [
      'error',
      {
        'newlines-between': 'always',
        alphabetize: { order: 'asc', caseInsensitive: true },
        pathGroups: [
          {
            pattern: '{react,react-native}',
            group: 'external',
            position: 'before',
          },
          {
            pattern: '{api,assets,common,components,hooks,navigators,screens,stores,themes,translations,utils}{/**,}',
            group: 'external',
            position: 'after',
          },
        ],
        "groups": [["builtin", "external"], "parent", "sibling", "index"],
        pathGroupsExcludedImportTypes: ['builtin'],
      },
    ],
    'import/prefer-default-export': 0,
    'react/jsx-filename-extension': [2, { extensions: ['.tsx', '.jsx'] }],
    'react/jsx-indent': 0,
    'react/jsx-one-expression-per-line': 0,
    'react/jsx-props-no-multi-spaces': 0, // Disabled because of bug https://github.com/yannickcr/eslint-plugin-react/issues/2181
    'react/prop-types': 0,
    'react/jsx-props-no-spreading': 0,
    'react/jsx-uses-react': 0,
    'react/react-in-jsx-scope': 0,
    'react/require-default-props': 0,
    "react/function-component-definition": 0,
    "react/no-unstable-nested-components": 0,
    "react/jsx-no-useless-fragment": 0,
    '@typescript-eslint/indent': 0,
    '@typescript-eslint/explicit-function-return-type': 0,
    '@typescript-eslint/explicit-module-boundary-types': 0, // TODO Review if it's needed
    '@typescript-eslint/no-empty-interface': 1,
    "@typescript-eslint/no-empty-function": 0,
    "@typescript-eslint/no-use-before-define": 0,
  },
};
