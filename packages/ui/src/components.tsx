/**
 * The shared React Native components, built 1:1 from the reference.
 *
 * **The one rule that outranks the others:** no component here composes an
 * availability string. Words come from `@ev-guide/domain`'s grammar, which is
 * the only place the eight display laws are enforced. A component that builds
 * its own "2 of 4 free" reintroduces exactly the failure that made
 * `availability-display.md` a single shared document.
 */
import type { ReactNode } from 'react';
import { Pressable, Text as RNText, View } from 'react-native';
import type { StyleProp, TextStyle, ViewStyle } from 'react-native';
import {
  buttonLabelStyle,
  buttonStyle,
  categoryChipLabelStyle,
  categoryChipStyle,
  dragHandleStyle,
  featureChipLabelStyle,
  featureChipStyle,
  stationCardStyle,
  textStyle,
  type Step,
  type Weight,
} from './styles';

/**
 * The typeface arrives from the app, never from here: it is an acceptance
 * band, not a name (ADR-0010). Leaving `fontFamily` undefined falls back to
 * the platform face, which is a legitimate state during development and an
 * illegitimate one at release.
 */
export interface TextProps {
  step?: Step;
  weight?: Weight;
  fontFamily?: string;
  style?: StyleProp<TextStyle>;
  numberOfLines?: number;
  children?: ReactNode;
}

export function Text({
  step = 'body',
  weight = 'regular',
  fontFamily,
  style,
  numberOfLines,
  children,
}: TextProps) {
  return (
    <RNText
      numberOfLines={numberOfLines}
      style={[textStyle(step, weight), fontFamily ? { fontFamily } : null, style]}
    >
      {children}
    </RNText>
  );
}

export interface ButtonProps {
  label: string;
  variant?: 'primary' | 'sticky';
  onPress?: () => void;
  disabled?: boolean;
  style?: StyleProp<ViewStyle>;
}

/**
 * State is carried by the accent or by copy, **never by a surface swap alone**
 * (ticket 31). The pressed state therefore moves opacity rather than swapping
 * the fill for a second accent value: there is no second accent value, and the
 * record's "accent shade #9EC52B" was anti-aliasing on pin outlines.
 */
export function Button({ label, variant = 'primary', onPress, disabled, style }: ButtonProps) {
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityState={{ disabled: !!disabled }}
      onPress={onPress}
      disabled={disabled}
      style={({ pressed }) => [
        buttonStyle(variant),
        pressed ? { opacity: 0.85 } : null,
        disabled ? { opacity: 0.5 } : null,
        style,
      ]}
    >
      <RNText style={buttonLabelStyle(variant)}>{label}</RNText>
    </Pressable>
  );
}

export interface FeatureChipProps {
  label: string;
  icon?: ReactNode;
  style?: StyleProp<ViewStyle>;
}

/** `04`'s chip: fixed height, width fits content, no border. */
export function FeatureChip({ label, icon, style }: FeatureChipProps) {
  return (
    <View style={[featureChipStyle(), style]}>
      {icon}
      <RNText style={featureChipLabelStyle()}>{label}</RNText>
    </View>
  );
}

/**
 * `03`'s chip: a pill with a lime border, and **asymmetric padding by
 * measurement** (86 left, 30 right). See [RAISE-5]. Do not centre the label.
 */
export function CategoryChip({ label, style }: { label: string; style?: StyleProp<ViewStyle> }) {
  return (
    <View style={[categoryChipStyle(), style]}>
      <RNText style={categoryChipLabelStyle()}>{label}</RNText>
    </View>
  );
}

export function DragHandle({ style }: { style?: StyleProp<ViewStyle> }) {
  return <View accessibilityElementsHidden style={[dragHandleStyle(), style]} />;
}

export interface StationCardProps {
  title: string;
  /**
   * Already-composed availability text, from `@ev-guide/domain`'s grammar.
   * Typed as a plain string on purpose: this component may **render** words,
   * never choose them.
   */
  availabilityText: string;
  distanceText?: string;
  thumbnail?: ReactNode;
  trailing?: ReactNode;
  showHandle?: boolean;
  style?: StyleProp<ViewStyle>;
}

/**
 * The `03` container. A **floating card, not a bottom sheet**: rounded on all
 * four corners, never anchored to the screen edge. Not built on a sheet
 * primitive, whose whole contract is the anchoring this card does not do.
 */
export function StationCard({
  title,
  availabilityText,
  distanceText,
  thumbnail,
  trailing,
  showHandle = true,
  style,
}: StationCardProps) {
  return (
    <View style={[stationCardStyle(), style]}>
      {showHandle ? <DragHandle /> : null}
      <View style={{ flexDirection: 'row', alignItems: 'flex-start' }}>
        {thumbnail}
        <View style={{ flex: 1 }}>
          <RNText style={textStyle('heading', 'bold')} numberOfLines={1}>
            {title}
          </RNText>
          <RNText style={textStyle('body', 'regular')} numberOfLines={2}>
            {distanceText ? `${distanceText} · ${availabilityText}` : availabilityText}
          </RNText>
        </View>
        {trailing}
      </View>
    </View>
  );
}
