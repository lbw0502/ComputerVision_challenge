function Cake = cake(min_dist)
    % Die Funktion cake erstellt eine "Kuchenmatrix", die eine kreisfoermige
    % Anordnung von Nullen beinhaltet und den Rest der Matrix mit Einsen
    % auffuellt. Damit koennen, ausgehend vom staerksten Merkmal, andere Punkte
    % unterdrueckt werden, die den Mindestabstand hierzu nicht einhalten. 
    % HA1.8
    for i=1:2*min_dist+1
        for j=1:2*min_dist+1
            dist=(i-(min_dist+1))^2+(j-(min_dist+1))^2;
            if dist>min_dist^2
                Cake(i,j)=true;
            else Cake(i,j)=false;
            end
        end
    end
    
end