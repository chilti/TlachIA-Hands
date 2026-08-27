import ldnlLogo from "#/assets/branding/ldnl-logo.png";
import { NavigationLink } from "#/components/shared/navigation-link";
import { cn } from "#/utils/utils";

const DEFAULT_LOGO_WIDTH = 34;
const DEFAULT_LOGO_HEIGHT = 34;

export type OpenHandsLogoButtonProps = {
  className?: string;
  /** Applied to the root `<image>` / container */
  logoClassName?: string;
  logoWidth?: number;
  logoHeight?: number;
};

export function OpenHandsLogoButton({
  className,
  logoClassName,
  logoWidth = DEFAULT_LOGO_WIDTH,
  logoHeight = DEFAULT_LOGO_HEIGHT,
}: OpenHandsLogoButtonProps = {}) {
  return (
    <NavigationLink
      to="/conversations"
      aria-label="TlachIA-Hands - Laboratorio de Dinámica No Lineal UNAM"
      className={cn("flex items-center gap-2 group", className)}
    >
      <img
        src={ldnlLogo}
        alt="Laboratorio de Dinámica No Lineal - UNAM"
        width={logoWidth}
        height={logoHeight}
        className={cn(
          "shrink-0 rounded-md object-contain transition-transform duration-200 group-hover:scale-105",
          logoClassName,
        )}
      />
    </NavigationLink>
  );
}
