export function MadagascarFlag({ className = "h-4 w-6" }: { className?: string }) {
  return (
    <svg 
      xmlns="http://w3.org" 
      viewBox="0 0 3 2" 
      className={`${className} inline-block rounded-sm shadow-sm border border-stone-200/50`}
    >
      {/* Bande Blanche verticale à gauche */}
      <rect width="1" height="2" fill="#FFF"/>
      {/* Bande Rouge horizontale en haut à droite */}
      <rect width="2" height="1" x="1" fill="#FC3D21"/>
      {/* Bande Verte horizontale en bas à droite */}
      <rect width="2" height="1" x="1" y="1" fill="#007E3A"/>
    </svg>
  );
}
export function CongoFlag({ className = "h-4 w-6" }: { className?: string }) {
  return (
    <svg 
      xmlns="http://w3.org" 
      viewBox="0 0 3 2" 
      className={`${className} inline-block rounded-sm shadow-sm border border-stone-200/50`}
    >
      {/* Fond Vert */}
      <rect width="3" height="2" fill="#00af50"/>
      {/* Bande diagonale Jaune et triangle Rouge */}
      <path d="M 0,2 L 3,0 L 3,2 Z" fill="#dc241f"/>
      <path d="M 0,2 L 1.2,2 L 3,0.8 L 3,0 L 1.8,0 L 0,1.2 Z" fill="#ffef00"/>
    </svg>
  );
}
