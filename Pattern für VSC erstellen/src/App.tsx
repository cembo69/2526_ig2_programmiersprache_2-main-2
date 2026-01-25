import { useState } from 'react';
import Group20 from './imports/Group20';
import { Download, Copy, Check } from 'lucide-react';
import { Button } from './components/ui/button';
import { toast } from 'sonner@2.0.3';

export default function App() {
  const [copied, setCopied] = useState(false);

  const handleCopyCSS = () => {
    const cssCode = `/* 3D Cube Pattern for VSCode */
.pattern-background {
  background-color: #1e1e1e;
  background-image: 
    linear-gradient(45deg, transparent 40%, rgba(94, 94, 94, 0.1) 40%, rgba(94, 94, 94, 0.1) 60%, transparent 60%),
    linear-gradient(-45deg, transparent 40%, rgba(100, 52, 52, 0.1) 40%, rgba(100, 52, 52, 0.1) 60%, transparent 60%);
  background-size: 100px 100px;
}`;
    
    navigator.clipboard.writeText(cssCode);
    setCopied(true);
    toast.success('CSS in die Zwischenablage kopiert!');
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-neutral-900 via-neutral-800 to-neutral-900 text-white">
      {/* Header */}
      <header className="border-b border-neutral-700 bg-neutral-900/50 backdrop-blur-sm">
        <div className="container mx-auto px-6 py-4">
          <h1 className="text-2xl font-semibold">3D Cube Pattern Generator</h1>
          <p className="text-sm text-neutral-400 mt-1">
            Geometrisches Muster für VSCode und Webprojekte
          </p>
        </div>
      </header>

      <main className="container mx-auto px-6 py-12">
        {/* Pattern Preview */}
        <div className="grid lg:grid-cols-2 gap-8 mb-12">
          {/* Single Pattern */}
          <div className="space-y-4">
            <h2 className="text-xl font-medium">Einzelnes Muster</h2>
            <div className="bg-white rounded-lg p-8 shadow-2xl">
              <div className="w-full max-w-md mx-auto aspect-square">
                <Group20 />
              </div>
            </div>
          </div>

          {/* Repeated Pattern */}
          <div className="space-y-4">
            <h2 className="text-xl font-medium">Wiederholtes Muster</h2>
            <div className="bg-white rounded-lg p-8 shadow-2xl overflow-hidden">
              <div className="grid grid-cols-2 gap-0">
                {[...Array(4)].map((_, i) => (
                  <div key={i} className="aspect-square">
                    <Group20 />
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* Large Tiled Preview */}
        <div className="space-y-4 mb-12">
          <h2 className="text-xl font-medium">Gekacheltes Pattern (4x4)</h2>
          <div className="bg-white rounded-lg p-4 shadow-2xl overflow-hidden">
            <div className="grid grid-cols-4 gap-0">
              {[...Array(16)].map((_, i) => (
                <div key={i} className="aspect-square">
                  <Group20 />
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Color Variations */}
        <div className="space-y-4 mb-12">
          <h2 className="text-xl font-medium">Farbvarianten</h2>
          <div className="grid md:grid-cols-3 gap-6">
            {/* Original */}
            <div className="space-y-2">
              <p className="text-sm text-neutral-400">Original</p>
              <div className="bg-white rounded-lg p-6 shadow-xl">
                <div className="aspect-square">
                  <Group20 />
                </div>
              </div>
            </div>

            {/* Blue Variant */}
            <div className="space-y-2">
              <p className="text-sm text-neutral-400">Blau-Variante</p>
              <div className="bg-white rounded-lg p-6 shadow-xl">
                <div className="aspect-square [--fill-0:#3B82F6]">
                  <Group20 />
                </div>
              </div>
            </div>

            {/* Purple Variant */}
            <div className="space-y-2">
              <p className="text-sm text-neutral-400">Lila-Variante</p>
              <div className="bg-white rounded-lg p-6 shadow-xl">
                <div className="aspect-square [--fill-0:#A855F7]">
                  <Group20 />
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Code Section */}
        <div className="bg-neutral-800 rounded-lg p-6 border border-neutral-700 space-y-4">
          <div className="flex items-center justify-between">
            <h2 className="text-xl font-medium">React Component Verwendung</h2>
            <Button 
              onClick={handleCopyCSS}
              variant="outline"
              size="sm"
              className="gap-2"
            >
              {copied ? (
                <>
                  <Check className="size-4" />
                  Kopiert!
                </>
              ) : (
                <>
                  <Copy className="size-4" />
                  CSS Kopieren
                </>
              )}
            </Button>
          </div>
          
          <div className="bg-neutral-900 rounded p-4 overflow-x-auto">
            <pre className="text-sm text-neutral-300">
              <code>{`import Group20 from './imports/Group20';

export default function MyComponent() {
  return (
    <div className="w-64 h-64">
      <Group20 />
    </div>
  );
}`}</code>
            </pre>
          </div>

          <div>
            <h3 className="text-sm font-medium mb-2">Farben anpassen:</h3>
            <div className="bg-neutral-900 rounded p-4 overflow-x-auto">
              <pre className="text-sm text-neutral-300">
                <code>{`<div className="w-64 h-64 [--fill-0:#YOUR_COLOR]">
  <Group20 />
</div>`}</code>
              </pre>
            </div>
          </div>
        </div>

        {/* Info Cards */}
        <div className="grid md:grid-cols-2 gap-6 mt-12">
          <div className="bg-neutral-800/50 border border-neutral-700 rounded-lg p-6">
            <h3 className="font-medium mb-2 flex items-center gap-2">
              <Download className="size-5 text-orange-500" />
              Für VSCode verwenden
            </h3>
            <p className="text-sm text-neutral-400">
              Exportiere das Pattern als PNG oder SVG und verwende es als Hintergrundbild 
              in deinen VSCode-Einstellungen oder als Teil deiner Präsentationen.
            </p>
          </div>

          <div className="bg-neutral-800/50 border border-neutral-700 rounded-lg p-6">
            <h3 className="font-medium mb-2 flex items-center gap-2">
              <Copy className="size-5 text-orange-500" />
              React Integration
            </h3>
            <p className="text-sm text-neutral-400">
              Verwende die Group20 Komponente direkt in deinen React-Projekten. 
              Passe Größe und Farben über CSS-Variablen an.
            </p>
          </div>
        </div>
      </main>
    </div>
  );
}
