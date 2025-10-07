export const themes = {
  github: `
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
      font-size: 16px;
      line-height: 1.6;
      color: #24292e;
      background-color: #ffffff;
      padding: 20px;
      max-width: 980px;
      margin: 0 auto;
    }
    h1, h2, h3, h4, h5, h6 {
      margin-top: 24px;
      margin-bottom: 16px;
      font-weight: 600;
      line-height: 1.25;
    }
    h1 {
      font-size: 2em;
      border-bottom: 1px solid #eaecef;
      padding-bottom: 0.3em;
    }
    h2 {
      font-size: 1.5em;
      border-bottom: 1px solid #eaecef;
      padding-bottom: 0.3em;
    }
    h3 { font-size: 1.25em; }
    h4 { font-size: 1em; }
    code {
      font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace;
      font-size: 85%;
      background-color: rgba(27,31,35,0.05);
      padding: 0.2em 0.4em;
      border-radius: 3px;
    }
    pre {
      background-color: #f6f8fa;
      padding: 16px;
      overflow: auto;
      border-radius: 6px;
    }
    pre code {
      background-color: transparent;
      padding: 0;
    }
    blockquote {
      margin: 0;
      padding: 0 1em;
      color: #6a737d;
      border-left: 0.25em solid #dfe2e5;
    }
    a {
      color: #0366d6;
      text-decoration: none;
    }
    a:hover {
      text-decoration: underline;
    }
    ul, ol {
      padding-left: 2em;
    }
    table {
      border-collapse: collapse;
      width: 100%;
      margin: 16px 0;
    }
    table th, table td {
      padding: 6px 13px;
      border: 1px solid #dfe2e5;
    }
    table th {
      font-weight: 600;
      background-color: #f6f8fa;
    }
  `,
  clean: `
    body {
      font-family: 'Georgia', serif;
      font-size: 16px;
      line-height: 1.8;
      color: #333;
      background-color: #fff;
      padding: 40px;
      max-width: 800px;
      margin: 0 auto;
    }
    h1, h2, h3, h4, h5, h6 {
      font-family: 'Helvetica Neue', Arial, sans-serif;
      margin-top: 32px;
      margin-bottom: 16px;
      font-weight: 700;
      line-height: 1.3;
      color: #222;
    }
    h1 { font-size: 2.5em; }
    h2 { font-size: 2em; }
    h3 { font-size: 1.5em; }
    h4 { font-size: 1.2em; }
    code {
      font-family: 'Courier New', monospace;
      font-size: 90%;
      background-color: #f5f5f5;
      padding: 2px 6px;
      border-radius: 3px;
      color: #c7254e;
    }
    pre {
      background-color: #f9f9f9;
      padding: 20px;
      border-left: 4px solid #ccc;
      overflow: auto;
      margin: 20px 0;
    }
    pre code {
      background-color: transparent;
      padding: 0;
      color: inherit;
    }
    blockquote {
      margin: 20px 0;
      padding: 10px 20px;
      background-color: #f9f9f9;
      border-left: 5px solid #ccc;
      font-style: italic;
      color: #666;
    }
    a {
      color: #0066cc;
      text-decoration: none;
      border-bottom: 1px solid transparent;
      transition: border-bottom 0.2s;
    }
    a:hover {
      border-bottom: 1px solid #0066cc;
    }
    ul, ol {
      padding-left: 30px;
      margin: 16px 0;
    }
  `,
  academic: `
    body {
      font-family: 'Times New Roman', Times, serif;
      font-size: 12pt;
      line-height: 2;
      color: #000;
      background-color: #fff;
      padding: 1in;
      max-width: 8.5in;
      margin: 0 auto;
    }
    h1, h2, h3, h4, h5, h6 {
      font-weight: bold;
      margin-top: 24pt;
      margin-bottom: 12pt;
      line-height: 1.2;
      text-align: left;
    }
    h1 {
      font-size: 18pt;
      text-align: center;
      margin-top: 0;
    }
    h2 {
      font-size: 14pt;
    }
    h3 {
      font-size: 12pt;
    }
    p {
      margin: 0;
      text-indent: 0.5in;
      text-align: justify;
    }
    p:first-of-type,
    h1 + p, h2 + p, h3 + p {
      text-indent: 0;
    }
    code {
      font-family: 'Courier New', monospace;
      font-size: 11pt;
    }
    pre {
      font-family: 'Courier New', monospace;
      font-size: 10pt;
      line-height: 1.5;
      border: 1px solid #ccc;
      padding: 12pt;
      margin: 12pt 0;
      background-color: #f9f9f9;
    }
    pre code {
      background-color: transparent;
    }
    blockquote {
      margin: 12pt 0.5in;
      padding: 0;
      font-style: italic;
    }
    a {
      color: #000;
      text-decoration: underline;
    }
    ul, ol {
      margin: 12pt 0;
      padding-left: 0.5in;
    }
    table {
      border-collapse: collapse;
      width: 100%;
      margin: 12pt 0;
      font-size: 11pt;
    }
    table th, table td {
      padding: 6pt;
      border: 1px solid #000;
    }
    table th {
      font-weight: bold;
      text-align: left;
    }
  `,
};
