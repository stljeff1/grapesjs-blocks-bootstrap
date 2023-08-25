const HtmlWebpackPlugin = require('html-webpack-plugin');
const TerserPlugin = require("terser-webpack-plugin");
const pkg = require('./package.json');
const webpack = require('webpack');
const fs = require('fs');
const name = pkg.name;
let plugins = [];
let optimization = {};


module.exports = (env = {}) => {
    if (env.production) {
        optimization.minimizer = [
            new TerserPlugin({
                parallel: true,
            })
        ];
        plugins = [
            new webpack.BannerPlugin(`${name} - ${pkg.version}`),
        ]
    } else {
        const index = 'index.html';
        const indexDev = '_' + index;
        plugins.push(new HtmlWebpackPlugin({
            template: fs.existsSync(indexDev) ? indexDev : index
        }));
    }

    return {
        mode: env.production ? 'production' : 'development',
        entry: './source',
        output: {
            filename: `./${name}.min.js`,
            library: name,
            libraryTarget: 'umd',
        },
        module: {
            rules: [
                {
                    test: /\.js$/,
                    include: /source/,
                    use: {
                        loader: 'babel-loader',
                    }
                },
            ],
        },
        externals: {'grapesjs': 'grapesjs'},
        optimization: optimization,
        plugins: plugins,
        watchOptions: {
            ignored: /node_modules/
        }
    };
};
