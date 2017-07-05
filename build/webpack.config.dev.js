const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const postcssReporter = require('postcss-reporter')({ clearMessages: true });
const postcssCalc = require('postcss-calc')();
const postcssCssnext = require('postcss-cssnext')({ browsers: ['last 2 versions'], features: { customProperties: false } });
const postcssAtroot = require('postcss-atroot');
const postcssExtend = require('postcss-extend');
const postcssMixins = require('postcss-mixins');
const postcssNested = require('postcss-nested');
const postcssImport = require('postcss-import');
const postcssPropertyLookup = require('postcss-property-lookup');
const postcssUrl = require('postcss-url')();
const postcssHexrgba = require('postcss-hexrgba')();

module.exports = {
    entry: '../src/index.js',
    output: {
        path: path.resolve(__dirname, '../dist'),
        filename: 'index.js'
    },

    module: {
        rules: [
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                use: {
                    loader: 'elm-webpack-loader',
                    options: {
                        debug: true
                    }
                }
            },
            {
                test: /\.css$/,
                use: [{ loader: 'style-loader' }, { loader: 'css-loader' }]
            },
            {
                test: /\.(woff2?|eot|ttf|otf|png|gif|jpg|jpeg|html|svg)(\?.*)?$/,
                loader: 'file-loader?name=[name].[ext]'
            },
            {
                test: /\.pcss$/,
                use: [
                    { loader: 'style-loader' },
                    { loader: 'css-loader', options: { importLoaders: 1 } },
                    {
                        loader: 'postcss-loader',
                        options: {
                            sourceMap: true,
                            plugins: () => [
                                postcssReporter,
                                postcssImport,
                                postcssNested,
                                postcssExtend,
                                postcssUrl,
                                postcssCalc,
                                postcssCssnext,
                                postcssAtroot,
                                postcssMixins,
                                postcssPropertyLookup,
                                postcssHexrgba
                            ]
                        }
                    }
                ]
            }
        ],
        noParse: [/.elm$/]
    },

    resolve: {
        extensions: [
            '.js',
            '.json',
            '.jsx',
            '.ts',
            '.tsx',
            '.css',
            '.jpg',
            '.jpeg',
            '.png',
            '.gif',
            '.elm'
        ]
    },

    devtool: 'source-map',
    context: __dirname,
    target: 'web',
    devServer: {
        proxy: {
            '/api': 'http://localhost:3000'
        },
        compress: false,
        historyApiFallback: false,
        hot: true,
        overlay: true
    }
};
