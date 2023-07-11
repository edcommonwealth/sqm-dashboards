const { cypressEsbuildPreprocessor } = require('cypress-esbuild-preprocessor');
const path = require('path');

module.exports = (on, config) => {
  on(
    'file:preprocessor',
    cypressEsbuildPreprocessor({
      esbuildOptions: {
        // optional tsconfig for typescript support and path mapping (see https://github.com/evanw/esbuild for all options)
        tsconfig: path.resolve(__dirname, '../../tsconfig.json'),
      },
    }),
  );
};
