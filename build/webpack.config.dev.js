const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

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
                    options: {}
                }
            },
            {
                test: /\.css$/,
                use: [{ loader: 'style-loader' }, { loader: 'css-loader' }]
            },
            {
                test: /\.(woff2?|eot|ttf|otf|png|gif|jpg|jpeg|html)(\?.*)?$/,
                loader: 'file-loader?name=[name].[ext]'
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
