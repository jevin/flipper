module Flipper
  module Adapters
    class Failover
      include ::Flipper::Adapter

      # Public: The name of the adapter.
      attr_reader :name

      # Public: Build a new failover instance.
      #
      # primary   - The primary flipper adapter.
      # secondary - The secondary flipper adapter which services reads when
      #             the primary adapter is unavailable.
      # options   - Hash of options:
      #             :dual_write - Boolean, whether to update secondary when
      #                           primary is updated
      #             :errors - Array of exception types for which to failover

      def initialize(primary, secondary, dual_write: false, errors: [ StandardError ])
        @name = :failover
        @primary = primary
        @secondary = secondary
        @dual_write = dual_write
        @errors = errors
      end

      def features
        @primary.features
      rescue *@errors
        @secondary.features
      end

      def get(feature)
        @primary.get(feature)
      rescue *@errors
        @secondary.get(feature)
      end

      def get_multi(features)
        @primary.get_multi(features)
      rescue *@errors
        @secondary.get_multi(features)
      end

      def get_all
        @primary.get_all
      rescue *@errors
        @secondary.get_all
      end

      def add(feature)
        @primary.add(feature).tap do
          @secondary.add(feature) if @dual_write
        end
      end

      def remove(feature)
        @primary.remove(feature).tap do
          @secondary.remove(feature) if @dual_write
        end
      end

      def clear(feature)
        @primary.clear(feature).tap do
          @secondary.clear(feature) if @dual_write
        end
      end

      def enable(feature, gate, thing)
        @primary.enable(feature, gate, thing).tap do
          @secondary.enable(feature, gate, thing) if @dual_write
        end
      end

      def disable(feature, gate, thing)
        @primary.disable(feature, gate, thing).tap do
          @secondary.disable(feature, gate, thing) if @dual_write
        end
      end
    end
  end
end
