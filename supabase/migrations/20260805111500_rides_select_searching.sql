-- A driver who has been *offered* a ride (via the incoming-ride push/
-- broadcast) is not yet its `driver_id` — `rides_select_participants_or_admin`
-- only allows the client, the assigned driver, or an admin to see a row, so
-- `TaxiFlowController.showIncomingRideById`'s fetch-by-id (the reliable
-- path to the accept/reject sheet, used because push delivery/the Realtime
-- broadcast can be delayed or missed) always returned nothing — RLS made
-- the row invisible before the driver had ever accepted it.
--
-- Opening visibility to any authenticated user while `status = 'searching'`
-- doesn't leak anything new: `request-ride` already broadcasts this same
-- pickup/dropoff/price/distance to every matched driver's own Realtime
-- channel and push notification the moment the ride is created. Once
-- accepted (status changes away from 'searching'), only the two
-- participants can see it again.
create policy "rides_select_searching"
  on public.rides for select
  to authenticated
  using (status = 'searching');
