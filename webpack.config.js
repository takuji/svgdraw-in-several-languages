module.exports = {
    entry: {
        es2015: './src/es2015/index.js',
        ts: './src/typescript/index.ts'
    },
    output: {
        path: './dist',
        filename: 'svgdraw-[name].js'
    },
    module: {
        loaders: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                loader: "babel"
            },
            {
                test: /\.tsx?$/,
                loader: "awesome-typescript-loader"
            }
        ]
    }
};
